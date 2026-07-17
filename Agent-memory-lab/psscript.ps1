Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,

    [string]
    $DeploymentID,

    [string]
    $vmAdminUsername,

    [string]
    $adminPassword,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword

)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath
 
# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
InstallAzPowerShellModule
InstallAzCLI
CloudLabsManualAgent Install

#Installing Modern VM Validator
InstallModernVmValidator

CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID

Enable-CloudLabsEmbeddedShadow $vmAdminUsername $trainerUserName $trainerUserPassword

sleep 10

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Verbose

#Install Visual Studio Code
choco install vscode -y -force

#Install Python 3.12
choco install python311 -y -force

#Install Azure-cli
#choco install azure-cli --version=2.51.0 -y -force
 
#Install git
choco install git -y

#Remove any existing installation of the ml extension and also the CLI v1 azure-cli-ml extension:

#az extension remove -n azure-cli-ml
#az extension remove -n ml

#install the ml extension:
az extension add -n ml
az ml -h
az extension update -n ml

#Download LogonTask
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/azure-aI-agents/scripts/logontask.ps1","C:\LabFiles\logontask-01.ps1")

#Enable Auto-Logon
$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\demouser" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value $adminPassword -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

Stop-Transcript
Restart-Computer -Force
