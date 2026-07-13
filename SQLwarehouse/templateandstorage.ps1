Start-Transcript -Path C:\WindowsAzure\Logs\templateandstorage.txt -Append

. C:\LabFiles\AzureCreds.ps1

$AppID          = $env:AppID
$AppSecret      = $env:AppSecret
$azuserobjectid = $env:azuserobjectid

if (-not $AppID -or -not $AppSecret) {
    Write-Error "AppID / AppSecret environment variables are not set. Cannot log in with SPN."
    exit 1
}

$securePassword = $AppSecret | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $AppID, $securePassword

Write-Host "Connecting to Azure with Service Principal..."
Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant $AzureTenantID -Subscription $AzureSubscriptionID | Out-Null

# Get Synapse Resource Group

$resourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "Synapse-AIAD*" } | Select-Object -First 1
if (-not $resourceGroup) {
    Write-Error "No resource group matching Synapse-AIAD* found."
    exit 1
}

$resourceGroupName = $resourceGroup.ResourceGroupName
$deploymentId      = (Get-AzResourceGroup -Name $resourceGroupName).Tags["DeploymentId"]

$workspacename     = "asaworkspace$deploymentId"
$asadatalakename   = "asadatalake$deploymentId"

# Detect storage account

$storageAccounts = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Storage/storageAccounts"
$storageName = $storageAccounts | Where-Object { $_.Name -like "asadatalake*" } | Select-Object -First 1
$blobstorageName = $storageAccounts | Where-Object { $_.Name -like 'asastore*' } | Select-Object -First 1
if (-not $storageName) {
    Write-Error "No storage account starting with 'asadatalake' found!"
    exit 1
}

$storage = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageName.Name
$storageContext = $storage.Context

$rgLocation = $resourceGroup.Location
Write-Host "Resource group: $resourceGroupName in $rgLocation"

# Select correct source SAS URL based on region

$rgLocationLower = $rgLocation.ToLower()

switch -Wildcard ($rgLocationLower) {
    "westus2" {
        $srcUrl = "https://synapsetiwestus2.blob.core.windows.net/?sv=2024-11-04&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2026-10-15T16:53:08Z&st=2025-10-15T08:38:08Z&spr=https&sig=nCQ9y%2F3rfW52Rg0ljW3I8KlwYtDMfr2t8YM%2Boy6rXjo%3D"
    }
    "westeurope" {
        $srcUrl = "https://synapsetiwesteurope.blob.core.windows.net/?sv=2024-11-04&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2026-10-15T00:11:19Z&st=2025-10-14T15:56:19Z&spr=https&sig=tDIbmp4oSdmfgPHaVMwDpd%2BCbG1flYII%2BhDmPu5vC4U%3D"
    }
    # Use the SAME SAS for eastus and eastus2
    "eastus" {
        $srcUrl = "https://synapsetieastus.blob.core.windows.net/?sv=2024-11-04&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2026-10-15T16:56:31Z&st=2025-10-15T08:41:31Z&spr=https&sig=r9eutsi%2FypI1%2F%2FgHk1wP%2B7f36HuOkOqJ6ro3W%2FlS5Qg%3D"
    }
    "eastus2" {
        $srcUrl = "https://synapsetieastus.blob.core.windows.net/?sv=2024-11-04&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2026-10-15T16:56:31Z&st=2025-10-15T08:41:31Z&spr=https&sig=r9eutsi%2FypI1%2F%2FgHk1wP%2B7f36HuOkOqJ6ro3W%2FlS5Qg%3D"
    }
    default {
        # Ideally update this to a fresh, valid SAS as well if you ever use it
        $srcUrl = "https://synapsetiblobnortheurope.blob.core.windows.net/?sv=2022-11-02&ss=b&srt=sco&sp=rwdlaciyx&se=2025-07-22T19:33:19Z&st=2024-07-22T11:33:19Z&spr=https&sig=7mo2dy38jfnwCsSXM7mKr5zmgJjIlTP8m27roZDyRIU%3D"
    }
}

# Generate SAS and run AzCopy

Write-Host "Generating SAS token..."

$expiry = (Get-Date).AddDays(2)
$destSASToken = New-AzStorageAccountSASToken `
    -Service Blob `
    -ResourceType Service,Container,Object `
    -Permission "rwdlac" `
    -StartTime (Get-Date).AddMinutes(-5) `
    -ExpiryTime $expiry `
    -Context $storage.Context

$destUrl = "$($storage.Context.BlobEndPoint)?$destSASToken"

Write-Host "`nSource URL:"
Write-Host $srcUrl
Write-Host "`nDestination URL:"
Write-Host $destUrl

Write-Host "`nRunning AzCopy..."
& "C:\LabFiles\azcopy.exe" copy $srcUrl $destUrl --recursive=true
$azcopyExitCode = $LASTEXITCODE

if ($azcopyExitCode -eq 0) {
    Write-Host "AzCopy completed successfully."
} else {
    Write-Warning "AzCopy failed with exit code $azcopyExitCode"
}

if(-not $blobstorageName)
{
    Write-Error "No storage account starting with 'asastore' found!"
    exit 1
}

. C:\LabFiles\datastore.ps1

# Assign Synapse Roles

$groupIds = @(
    "b9856f36-18ca-4fdf-8715-f82316f965b4",
    "37548b2e-e5ab-4d2b-b0da-4d812f56c30e"
)

$roleIds = @(
    "6e4bf58a-b8e1-4cc3-bbf9-d73143322b78",
    "7af0c69a-a548-47d6-aea3-d00e69bd83aa",
    "c3a6d2f1-a26f-4810-9b0f-591308d5cbf1"
)

Write-Host "`nAssigning roles..."

foreach ($groupId in $groupIds) {
    foreach ($roleId in $roleIds) {
        try {
            New-AzSynapseRoleAssignment -WorkspaceName $workspacename -RoleDefinitionId $roleId -ObjectId $groupId -ErrorAction Stop
            Write-Host "Assigned role $roleId -> $groupId"
        }
        catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Host "Role already exists for $groupId - skipping"
            } else {
                Write-Warning ("Failed assigning role: " + $_.Exception.Message)
            }
        }
    }
}

# Assign Synapse Administrator Role
 
$workspaceName = "asaworkspace$deploymentId"
 
Write-Host "Assigning Synapse Administrator role to ObjectId: $azuserobjectid on workspace: $workspaceName"
 
try {
    New-AzSynapseRoleAssignment `
        -WorkspaceName $workspaceName `
        -RoleDefinitionName "Synapse Administrator" `
        -ObjectId $azuserobjectid `
        -ErrorAction Stop
 
    Write-Host "Synapse Administrator role assigned successfully."
}
catch {
    Write-Warning "Failed to assign Synapse Admin role: $($_.Exception.Message)"
 
}
# Get SPN object id for the AppID weâ€™re using to log in
$spn = Get-AzADServicePrincipal -ApplicationId $AppID
$spnObjectId = $spn.Id

Write-Host "Assigning Synapse Administrator role to SPN ObjectId: $spnObjectId on workspace: $workspaceName"

try {
    New-AzSynapseRoleAssignment `
        -WorkspaceName     $workspaceName `
        -RoleDefinitionName "Synapse Administrator" `
        -ObjectId          $spnObjectId `
        -ErrorAction       Stop

    Write-Host "Synapse Administrator role assigned successfully to SPN."
}
catch {
    Write-Warning "Failed to assign Synapse Admin role to SPN: $($_.Exception.Message)"
} 

Logout-AzAccount

$batPath = "C:\LabFiles\automation.bat"
Write-Host "Starting automation.bat..."

Start-Process -FilePath $batPath -WindowStyle Hidden

Start-Sleep -Seconds 10

$fileToCheck = "C:\LabFiles\Logs\Logfile.txt"

if (!(Test-Path $fileToCheck -PathType Leaf)) {
    Write-Warning "Logfile not found. Restarting automation.bat..."
    Start-Process -FilePath $batPath -WindowStyle Hidden
}

Start-Sleep -Seconds 1500

Write-Host "automation.bat phase completed. Continuing script..."

cd 'C:\LabFiles\'

.\validate.ps1

# Cleanup & Agent Start


$pluginRoot = Get-ChildItem "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension" -Directory | 
              Sort-Object Name -Descending | Select-Object -First 1

$commonscriptpath = Join-Path $pluginRoot.FullName "Downloads\0\cloudlabs-common\cloudlabs-windows-functions.ps1"

if (Test-Path $commonscriptpath) {
    . $commonscriptpath
    CloudlabsManualAgent Start
    Write-Host "CloudLabs Agent Started"
}

Unregister-ScheduledTask -TaskName "Setup" -Confirm:$false -ErrorAction SilentlyContinue

Stop-Transcript
