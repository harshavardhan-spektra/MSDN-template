Start-Transcript -Path C:\WindowsAzure\Logs\validatelogs.txt -Append
$InformationPreference = "Continue"

cd 'C:\LabFiles\'

# Load module + lab credentials

Import-Module ".\validationscript.psm1"
. C:\LabFiles\AzureCreds.ps1  

# Login to Azure using Service Principal (NO user/password)

$AppID     = $env:AppID
$AppSecret = $env:AppSecret

if (-not $AppID -or -not $AppSecret) {
    Write-Error "AppID / AppSecret environment variables are not set. Cannot log in with SPN."
    exit 1
}

$securePassword = $AppSecret | ConvertTo-SecureString -AsPlainText -Force
$cred           = New-Object System.Management.Automation.PSCredential -ArgumentList $AppID, $securePassword

Write-Host "Connecting using Service Principal for validation..."

Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant $AzureTenantID | Out-Null

# If subscription is not set in AzureCreds, auto-detect one
if ([string]::IsNullOrWhiteSpace($AzureSubscriptionID)) {
    $sub = Get-AzSubscription | Select-Object -First 1
    if (-not $sub) {
        throw "No subscription found after SPN login."
    }
    $AzureSubscriptionID = $sub.Id
    Write-Host "Auto-detected subscription: $AzureSubscriptionID"
}

Set-AzContext -SubscriptionId $AzureSubscriptionID | Out-Null

# Basic environment / naming

$resourceGroupName = (Get-AzResourceGroup |
    Where-Object {
        $_.ResourceGroupName -like "Synapse-AIAD*" -and
        $_.ResourceGroupName -notlike "*internal*" -and
        $_.ResourceGroupName -notlike "*databricks*"
    } |
    Select-Object -First 1).ResourceGroupName

if (-not $resourceGroupName) {
    throw "The Synapse-AIAD* resource group does not exist in this subscription."
}

$uniqueId       = $DeploymentID
$subscriptionId = $AzureSubscriptionID
$tenantId       = $AzureTenantID
$global:logindomain = $tenantId   # used by token functions in the module

$workspaceName          = "asaworkspace$($uniqueId)"
$sqlPoolName            = "SQLPool01"
$sparkPoolName          = "SparkPool01"
$global:sqlEndpoint     = "$($workspaceName).sql.azuresynapse.net"
$global:sqlUser         = "asa.sql.admin"

# SQL password (same as automation-setup.ps1; some module functions may rely on it)
$global:sqlPassword = "password.1!!"

# SPN-based token bodies for validationscript.psm1

Add-Type -AssemblyName System.Web
$encodedClientSecret = [System.Web.HttpUtility]::UrlEncode($AppSecret)

$global:ropcBodySynapse    = "client_id=$($AppID)&client_secret=$($encodedClientSecret)&grant_type=client_credentials&scope=https://dev.azuresynapse.net/.default"
$global:ropcBodySynapseSQL = "client_id=$($AppID)&client_secret=$($encodedClientSecret)&grant_type=client_credentials&scope=https://sql.azuresynapse.net/.default"
$global:ropcBodyManagement = "client_id=$($AppID)&client_secret=$($encodedClientSecret)&grant_type=client_credentials&scope=https://management.azure.com/.default"

# Token caches expected by validationscript.psm1
$global:synapseToken    = ""
$global:synapseSQLToken = ""
$global:managementToken = ""

$global:tokenTimes = [ordered]@{
    Synapse    = (Get-Date -Year 1)
    SynapseSQL = (Get-Date -Year 1)
    Management = (Get-Date -Year 1)
}


# IDs used later for role assignments / checks

$rgname = $resourceGroupName
$id     = (Get-AzADServicePrincipal -DisplayName $workspaceName).Id   # workspace MSI
=
# Validation logic

$overallStateIsValid = $true

$asaArtifacts = [ordered]@{
    "asadatalake01" = @{
        Category = "linkedServices"
        Valid    = $false
    }
    "KeyVault" = @{
        Category = "linkedServices"
        Valid    = $false
    }
    "asastore01" = @{
        Category = "linkedServices"
        Valid    = $false
    }
    "sqlpool01" = @{
        Category = "linkedServices"
        Valid    = $false
    }
    "CognitiveService" = @{
        Category = "linkedServices"
        Valid    = $false
    }
    "CognitiveRESTEndpoint" = @{
        Category = "linkedServices"
        Valid    = $false
    }
}

foreach ($asaArtifactName in $asaArtifacts.Keys) {
    Write-Information "Checking $($asaArtifactName) in $($asaArtifacts[$asaArtifactName]["Category"])"
    $result = Get-AzSynapseLinkedService -WorkspaceName $workspaceName -Name $asaArtifactName
    if ($result -eq $null) {
        Write-Warning "Not found!"
        $overallStateIsValid = $false
    }
    else {
        Write-Information "OK"
    }
}

# Check Spark pool 
Write-Information "Checking Spark pool $($sparkPoolName)"
$sparkPool = Get-SparkPool -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -SparkPoolName $sparkPoolName
if ($sparkPool -eq $null) {
    Write-Warning "    The Spark pool $($sparkPoolName) was not found"
    $overallStateIsValid = $false
} else {
    Write-Information "OK"
}

# Check SQL pool 
$sqlPool = Get-SQLPool -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -SQLPoolName $sqlPoolName 

if ($sqlPool -eq $null) { 
    Write-Warning "The SQL pool $($sqlPoolName) was not found" 
    $overallStateIsValid = $false
} 
else { 
    Write-Information "OK"
 
    # Check SQL pool status 
    $sqlpoolstatus = Get-SQLPool -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -WorkspaceName $workspaceName -SQLPoolName $sqlPoolName 

    if ($sqlpoolstatus.properties.status -ne "Online") { 
        Write-Host "$uniqueId : SQLPOOL is paused" -ForegroundColor Yellow
    } 
    else { 
        Write-Host "$uniqueId : SQLPOOL is $($sqlpoolstatus.properties.status) " -ForegroundColor Yellow
    } 
}   

# Pipeline checks
$pipelineresult = Query-pipeline -WorkspaceName $workspaceName

$ExpectedPipelineName = @(
    'Import WWI Data', 
    'Import WWI Data - Fact Sale Full', 
    'Import WWI Perf Data - Fact Sale Fast', 
    'Import WWI Perf Data - Fact Sale Slow'
)

$count = 0

$pipelineresult.value | ForEach-Object {
    if ( ($_.status -eq "Succeeded") -and ($ExpectedPipelineName -contains $_.pipelineName ) ) {
        Write-Output " " $workspacename $_.pipelineName  $_.status
        $count++
    } 
    else {
        Write-Output " " $workspacename $_.pipelineName  $_.status
        $overallStateIsValid = $false
    }
}

if ($pipelineresult.value.Count -eq 0 ){
    $overallStateIsValid = $false
}   
elseif ($count -ne $ExpectedPipelineName.Count){
    $overallStateIsValid = $false
}
else {
    Write-Information "Pipeline runs ok"
}

# Check for SQLOnDemand database
$dbname = "SQLOnDemand01"
$db     = Get-Synapse-db -WorkspaceName $workspaceName

if ($db.items.name -eq $null) { 
    Write-Warning "The database $($dbname) was not found" 
    $overallStateIsValid = $false
} 
elseif ($db.items.name -eq $dbname) { 
    Write-Information "The database $($dbname) is present"
} 
else { 
    $overallStateIsValid = $false
    Write-Information "Database was not found"
}

if ($overallStateIsValid -eq $true) {
    Write-Information "Validation Passed"
    $validstatus = "Successfull"
}
else {
    Write-Warning "Validation Failed - see log output"
    $validstatus = "Failed"
}

Function SetDeploymentStatus($ManualStepStatus, $ManualStepMessage)
{
    (Get-Content -Path "C:\WindowsAzure\Logs\status-sample.txt") |
        ForEach-Object {$_ -Replace "ReplaceStatus", "$ManualStepStatus"} |
        Set-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt"

    (Get-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt") |
        ForEach-Object {$_ -Replace "ReplaceMessage", "$ManualStepMessage"} |
        Set-Content -Path "C:\WindowsAzure\Logs\validationstatus.txt"
}

if ($validstatus -eq "Successfull") {
    $ValidStatus  = "Succeeded"
    $ValidMessage = "Environment is validated and the deployment is successful"
    Remove-Item 'C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt' -Force
}
else {
    Write-Warning "Validation Failed - see log output"
    $ValidStatus  = "Failed"
    $ValidMessage = "Environment Validation Failed and the deployment is Failed"
}

SetDeploymentStatus $ValidStatus $ValidMessage

Start-Sleep -Seconds 5

Stop-Transcript
