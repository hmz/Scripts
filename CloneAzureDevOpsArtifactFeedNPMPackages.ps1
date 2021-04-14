# npx vsts-npm-auth -config .npmrc
# NPM package count of source Azure DevOps Artifact Feed
$npmPackageCount = <Your_NPM_packages_count>

$url = "https://feeds.dev.azure.com/{organization}/{project}/_apis/Packaging/Feeds/{feedId}/Packages?includeDescription=true&%24top="+$npmPackageCount+"&includeDeleted=false"

$pat = ":<Your_PAT>"
$b  = [System.Text.Encoding]::ASCII.GetBytes($pat)
$token = [System.Convert]::ToBase64String($b)

# Get list of Azure DevOps NPM packages
$packageList = Invoke-RestMethod -Uri $url -Method GET -Headers @{
    'Authorization' = "Basic $token";
    'Content-Type' = "application/json"
}

# Bulk download Azure DevOps NPM packages 
foreach ($package in $packageList.value) {
    $packageUrl = "https://pkgs.dev.azure.com/{organization}/{project}/_apis/packaging/feeds/{feedId}/npm/packages/"+$package.name.ToString()+"/versions/"+$package.versions[0].version+"/content?api-version=5.0-preview.1"
    Invoke-RestMethod -Uri $packageUrl -Method GET -Headers @{ 'Authorization' = "Basic $token" } -OutFile $("C:\Temp\"+$package.name.ToString()+"-"+$package.versions[0].version+".tgz")
}

# Edit your .npmrc file to publish your packages to target Azure DevOps Artifact Feed
Get-ChildItem "C:\Temp" -Filter *.tgz | Foreach-Object { npm publish $_.FullName }
