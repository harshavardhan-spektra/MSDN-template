Param (
    [Parameter(Mandatory = $true)][string]$AzureUserName,
    [string]$AzurePassword,
    [string]$AzureTenantID,
    [string]$AzureSubscriptionID,
    [string]$ODLID,
    [string]$DeploymentID,
    [string]$azuserobjectid,
    [string]$InstallCloudLabsShadow,
    [string]$adminUsername,
    [string]$adminPassword,
    [string]$location,
    [string]$trainerUserName,
    [string]$trainerUserPassword,
    [string]$vmAdminUsername,
    [string]$AppID,
    [string]$AppSecret
)

# Basic parsing of UPN (kept in case you need tenant name later)
$Inputstring = $AzureUserName
$CharArray   = $InputString.Split("@")

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Write-Output "TLS setting: $([Net.ServicePointManager]::SecurityProtocol)"

# Expose SP and object id as machine env vars (CloudLabs convention)
[System.Environment]::SetEnvironmentVariable('AppID', $AppID, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AppSecret', $AppSecret, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('azuserobjectid', $azuserobjectid, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AzureSubscriptionID', $AzureSubscriptionID, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('AzureTenantID', $AzureTenantID, [System.EnvironmentVariableTarget]::Machine)

# CloudLabs common functions

$path = (Get-Location).Path
$commonscriptpath = "$path\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

#InstallManualStatusAgent
CloudlabsManualAgent Install

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
#InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow

Function CreateCredFile($AzureUserName, $AzurePassword, $AzureTenantID, $AzureSubscriptionID, $DeploymentID, $AppID, $AppSecret)
{
    New-Item -ItemType directory -Path C:\LabFiles -force

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://raw.githubusercontent.com/harshavardhan-spektra/MSDN-template/refs/heads/main/SQLwarehouse/AzureCreds.txt","C:\LabFiles\AzureCreds.txt")
    $WebClient.DownloadFile("https://raw.githubusercontent.com/harshavardhan-spektra/MSDN-template/refs/heads/main/SQLwarehouse/AzureCreds.ps1","C:\LabFiles\AzureCreds.ps1")

    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AppIDValue", "$AppID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AppSecretValue", "$AppSecret"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"

    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureUserNameValue", "$AzureUserName"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzurePasswordValue", "$AzurePassword"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureTenantIDValue", "$AzureTenantID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "AzureSubscriptionIDValue", "$AzureSubscriptionID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.ps1") | ForEach-Object {$_ -Replace "DeploymentIDValue", "$DeploymentID"} | Set-Content -Path "C:\LabFiles\AzureCreds.ps1"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AppIDValue", "$AppID"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"
    (Get-Content -Path "C:\LabFiles\AzureCreds.txt") | ForEach-Object {$_ -Replace "AppSecretValue", "$AppSecret"} | Set-Content -Path "C:\LabFiles\AzureCreds.txt"

    Copy-Item "C:\LabFiles\AzureCreds.txt" -Destination "C:\Users\Public\Desktop"
}

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID $AppID $AppSecret
InstallModernVmValidator


# Enable CloudLabs Embedded Shadow Feature (trainer ↔ VM)

$vmAdminUsername = $adminUsername

Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword

InstallChocolatey

#Enable Autologon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String  
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$adminPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

Stop-Transcript
Start-Sleep -Seconds 5
Restart-Computer -Force
