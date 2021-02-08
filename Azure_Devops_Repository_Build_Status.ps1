
Write-Host "Start"
$personalToken = "<TOKEN>"
$projectURL = "https://dev.azure.com/<PROJECT_NAMEE>/_apis/"


  $host.SetShouldExit($exitcode)
  exit
}
function GetBuildStatus(){
    param(
        [string]$target_repo
    )

    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
    $header = @{authorization = "Basic $token"}

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "PAT", $personalToken)))
    $headers = @{
        Authorization = "Basic $($base64AuthInfo)"
    }

    Write-Host "Get module definition " $target_repo
    $relDefUrl = $projectURL+"/build/definitions?api-version=5.0"
    $result = Invoke-RestMethod $relDefUrl -Method Get -ContentType "application/json" -Headers $header
    $relDefs = $result.value
    
    if($relDefs.count -gt 0){
        #Write-Host "$project $($relDefs.count) build def founds" -ForegroundColor Red
        $relDefs | ForEach-Object {
            if ($_.name -eq $target_repo)
                { 
                    Write-host "name = $($_.name)"
                    $definition_obj= $($_)
                }
        }
    }

    Write-Host "Get build definition according with the module"
    $definition_id=$definition_obj.id
    $relDefUrl = $projectURL+"/build/builds?definitions="+$definition_id+"&api-version=5.0"
    
    $result = Invoke-RestMethod $relDefUrl -Method Get -ContentType "application/json" -Headers $header
    $relDefs = $result.value
    $check_st=0
    $curr_build_num=0

    if($relDefs.count -gt 0){
    $lastBuild = $relDefs[0]
    $curr_build_num=$lastBuild.id
    $last_build_status = $lastBuild.result
    
    Write-host "last built id  = "$curr_build_num
    Write-host "last built status  = "$last_build_status -ForegroundColor Green
    
    if (!$last_build_status -eq "succeeded" -or $last_build_status -eq "")
       {
         Write-host "Detected build error!" -ForegroundColor Red
       }
    }
}


#Getting CI-HelloWorld build status 
$target_repo="CI-HelloWorld"
Write-Host "Module Name  " $target_repo
GetBuildStatus $target_repo
Write-Host "*******************************************************************************"

a
