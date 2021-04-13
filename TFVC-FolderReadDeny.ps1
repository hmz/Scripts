$url = "https://dev.azure.com/{organization}/_apis/accesscontrolentries/{securityNamespaceId}"

$pat = ":<YOUR_PAT>"
$b  = [System.Text.Encoding]::ASCII.GetBytes($pat)
$token = [System.Convert]::ToBase64String($b)

$bodyPart1=@'
{"token":"$/<YOUR_PROJECT>/<YOUR_BRANCH>/
'@

$bodyPart2=@'
","merge":true,"accessControlEntries":[{"descriptor":"Microsoft.TeamFoundation.Identity;<IDENTITY_ID>","allow":0,"deny":1,"extendedInfo":{"effectiveAllow":0,"effectiveDeny":1,"inheritedAllow":0,"inheritedDeny":1}}]}
'@

$pathList = @('FOLDER','PATH','LIST','ITEMS')

foreach ($path in $pathList) {
    $body = $bodyPart1 + $path + $bodyPart2
    Invoke-RestMethod -Uri $url -Method POST -Body $body -Headers @{ 
    'Authorization' = "Basic $token";
    'Content-Type' = "application/json" 
    } 
}
