Param (
    [Parameter(Mandatory = $true)][string]$AzureUserName,
    [string]$AzurePassword,
    [string]$AzureTenantID,
    [string]$AzureSubscriptionID,
    [string]$ODLID,
    [string]$DeploymentID,
    [string]$azuserobjectid,
    [string]$adminPassword,
    [string]$location,
    [string]$trainerUserName,
    [string]$trainerUserPassword,
    [string]$vmAdminUsername,
    [string]$AppID,
    [string]$AppSecret
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Write-Output "TLS setting: $([Net.ServicePointManager]::SecurityProtocol)"

# Expose SP and object id as machine env vars (CloudLabs convention)
[System.Environment]::SetEnvironmentVariable('AppID', $AppID, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AppSecret', $AppSecret, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('azuserobjectid', $azuserobjectid, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AzureSubscriptionID', $AzureSubscriptionID, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AzureTenantID', $AzureTenantID, [System.EnvironmentVariableTarget]::Machine)

$path = (Get-Location).Path
$commonscriptpath = "$path\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID


# Enable CloudLabs Embedded Shadow Feature (trainer ↔ VM)

Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword

#Enable Autologon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String  
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$adminPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

Stop-Transcript
Start-Sleep -Seconds 5
Restart-Computer -Force
