Start-Transcript -Path C:\WindowsAzure\Logs\LogonTask.txt -Append

$commonscriptpath = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.*\Downloads\0\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

cd c:\labfiles

git clone https://github.com/james-tn/agent-memory

python.exe -m pip install --upgrade pip
pip install uv

if (Test-Path "C:\labfiles\agent-memory" -PathType Container) {
    $Validstatus = "Succeeded"  ## Failed or Successful at the last step
    $Validmessage = "Post Deployment is successful"
}
else {
    Write-Warning "Validation Failed - see log output"
    $Validstatus = "Failed"  ## Failed or Successful at the last step
    $Validmessage = "Post Deployment Failed"
}

#Set the final deployment status
CloudlabsManualAgent setStatus

CloudLabsManualAgent Start

Unregister-ScheduledTask -TaskName "Setup" -Confirm:$false
Stop-Transcript
