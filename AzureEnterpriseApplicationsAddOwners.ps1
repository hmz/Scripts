Install-Module AzureAD -Scope CurrentUser -Repository PSGallery -Force
Import-module AzureAD
Connect-AzureAD

# Define users
$userEmails = @(
    "user1@asd.net",
    "user2@asd.net",
    "user3@asd.net",
    "user4@asd.net",
    "user5@asd.net"
)

$users = $userEmails | ForEach-Object { Get-AzureADUser -ObjectId $_ }

# Get user ObjectIds
$userIds = $users.ObjectId

# Define app names
$appNames = @(
    "aks1_principle",
    "aks2_principle",
    "aks3_principle"
)

# Add owners for each app
foreach ($appName in $appNames) {
    $sp = Get-AzureADServicePrincipal -Filter "displayName eq '$appName'"
    foreach ($userId in $userIds) {
        Add-AzureADServicePrincipalOwner -ObjectId $sp.ObjectId -RefObjectId $userId
        Write-Host "User $($userId) added as an owner to $($appName)"
    }
} 