$connectionName = "AzureRunAsConnection"
try
{

   # Get the connection "AzureRunAsConnection "
   $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName 
   Write-output("<INFO> Logging in to Azure...");
   Write-output("<INFO> TenantId:              " + $servicePrincipalConnection.TenantId)
   Write-output("<INFO> ApplicationId:         " + $servicePrincipalConnection.ApplicationId)
   Write-output("<INFO> CertificateThumbprint: " + $servicePrincipalConnection.CertificateThumbprint)

   Add-AzureRmAccount `
       -ServicePrincipal `
       -TenantId $servicePrincipalConnection.TenantId `
       -ApplicationId $servicePrincipalConnection.ApplicationId `
       -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch{
   if (!$servicePrincipalConnection)
   {
       $ErrorMessage = "Connection $connectionName not found."
       throw $ErrorMessage
   } else{
       Write-Error -Message $_.Exception
       throw $_.Exception
   }
}

Write-output("<SUCCESS> Login to Azure Successful.")

#specify Key vaults to exclude
$excludedKeyVaults = ""
#specify Applications object id to grant access policies to
$objectIds = "f81cf819-f710-4c99-abd0-2af561dba51e"


try
{
   #List all the subscription key vaults...
   Write-output("<INFO> Listing key vaults...")
   $KeyVaults = Get-AzureRmKeyVault # Note that Azure Documention specifies as Get-AzureRMKeyVault (Capital M which cause a failure)
   Write-output("<SUCCESS> Found " + $KeyVaults.Count + " Key vaults")
} catch {
   Write-output("<ERROR> Failed to list KeyVaults:")
   Write-Error -Message $_.Exception
   throw $_.Exception
}


# Iterate all key vaults found
foreach($KeyVault in $KeyVaults)
{
   try
   {
       # Skip specified excluded key vaults
       if($excludedKeyVaults -contains $KeyVault.VaultName)
       {
           Write-output("<WARN> Skipping " + $KeyVault.VaultName + ". Set in excluded Key vaults.")
       }
       else {      
           Write-output("<INFO> Start handling Key vault " + $KeyVault.VaultName + "...")
           # Iterate all object ids to grant access policies to
           foreach($objectId in $objectIds)
           {
               Write-output("<INFO> Granting access policies to objectId " + $objectId + " ...")
               $output = $null;
               $output = Set-AzureRmKeyVaultAccessPolicy -BypassObjectIdValidation -VaultName $KeyVault.VaultName -ObjectId $objectId -PermissionsToKeys 'list' -PermissionsToSecrets 'list' -PermissionsToCertificates get, list 2>&1
                
                   if(!$output)
                   {
                       Write-output("<SUCCESS> " + $KeyVault.VaultName + " Access policies granted successfully for objectId " + $objectId)  
                   } else {
                       Write-output("<ERROR> Failed to grant access policies to objectId " + $objectId)
                   }
           }

           #Optional - print the updated key vault object access policies
           #$CurrentKeyvault = Get-AzureRMKeyVault -VaultName $KeyVault.VaultName
           #Write-output($CurrentKeyvault.AccessPoliciesText)

           Write-output("<INFO> Finshied handling key vault " + $KeyVault.VaultName)
       }
   }
   catch {
       Write-output("<ERROR> Failed to set permissions for KeyVault " + $KeyVault.VaultName)
       Write-Error -Message $_.Exception
       throw $_.Exception
   }
}
