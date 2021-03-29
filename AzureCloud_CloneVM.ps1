####################### CREATE DISKS ########################

#Enter name of the ResourceGroup in which you have the snapshots
$resourceGroupName ='YOUR_RG_NAME'

#Enter name of the snapshot that will be used to create Managed Disks
$snapshotName = 'vm-os-c-disk'
$snapshotName2 = 'vm-DataDisk-f-disk'
$snapshotName3 = 'vm-DataDisk2-s-disk'

#Enter name of the Managed Disk
$diskName = 'OsDisk'
$diskName2 = 'DataDisk'
$diskName3 = 'DataDisk2'

#Enter size of the disk in GB
$diskSize = '128'
$diskSize2 = '256'
$diskSize3 = '256'

#Enter the storage type for Disk. PremiumLRS / StandardLRS.
$storageType = 'Premium_LRS'

#Enter the Azure region where Managed Disk will be created. It should be same as Snapshot location
$location = 'westeurope'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzureRmSubscription -SubscriptionId 'YOUR_SUBSCRIPTION_ID'

#Get the Snapshot ID by using the details provided
$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 
$snapshot2 = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName2 
$snapshot3 = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName3 

#Create a new Managed Disk from the Snapshot provided 
$disk = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id
$disk2 = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot2.Id
$disk3 = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot3.Id

New-AzureRmDisk -Disk $disk -ResourceGroupName $resourceGroupName -DiskName $diskName
New-AzureRmDisk -Disk $disk2 -ResourceGroupName $resourceGroupName -DiskName $diskName2
New-AzureRmDisk -Disk $disk3 -ResourceGroupName $resourceGroupName -DiskName $diskName3

#Get created disks
$disk = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName
$disk2 = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName2
$disk3 = Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $diskName3

####################### CREATE VM ########################

#Enter the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = 'YOUR_VNET_NAME'

#Enter the name of the virtual machine to be created
$virtualMachineName = 'YOUR_NEW_VM_NAME'

#Provide the size of the virtual machine
$virtualMachineSize = 'Standard_B4ms'

#Initialize virtual machine configuration
$VirtualMachine = New-AzureRmVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

#(Optional Step) Add data disk to the configuration. Enter DataDisk Id
$VirtualMachine = Add-AzureRmVMDataDisk -VM $VirtualMachine -Name $diskName2 -ManagedDiskId $disk2.Id -Lun "0" -CreateOption "Attach"
$VirtualMachine = Add-AzureRmVMDataDisk -VM $VirtualMachine -Name $diskName3 -ManagedDiskId $disk3.Id -Lun "1" -CreateOption "Attach"

#Use the Managed Disk Resource Id to attach it to the virtual machine. Use OS type based on the OS present in the disk - Windows / Linux
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Windows

#Create a public IP 
$publicIp = New-AzureRmPublicIpAddress -Name ($VirtualMachineName.ToLower()+'_ip') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -AllocationMethod Static

#Get VNET Information
$vnet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName

# Create NIC for the VM
$nic = New-AzureRmNetworkInterface -Name ($VirtualMachineName.ToLower()+'_nic') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id

$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

#Create the virtual machine with Managed Disk
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $resourceGroupName -Location $snapshot.Location

