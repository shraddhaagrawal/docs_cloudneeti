$connectionName = "AzureRunAsConnection"
try
{

   # Get the connection "AzureRunAsConnection "
   $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName 
   Write-output("Logging in to Azure...");
   Write-output("TenantId:              " + $servicePrincipalConnection.TenantId)
   Write-output("ApplicationId:         " + $servicePrincipalConnection.ApplicationId)
   Write-output("CertificateThumbprint: " + $servicePrincipalConnection.CertificateThumbprint)

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

Write-output("Login to Azure Successful.")

#specify Applications object id to grant access policies to
$ServicePrincipalId = Get-AutomationVariable -Name "ServicePrincipalId"


try
{
   #List all the subscription key vaults...
   Write-output(" Listing key vaults...")
   $KeyVaults = Get-AzureRmKeyVault
   Write-output("Found " + $KeyVaults.Count + " Key vaults")
} catch {
   Write-output("Failed to list KeyVaults:")
   Write-Error -Message $_.Exception
   throw $_.Exception
}


# Iterate all key vaults found
foreach($KeyVault in $KeyVaults)
{
   try
   {   
           Write-output(" Start handling Key vault " + $KeyVault.VaultName + "...")
           # Iterate all object ids to grant access policies to
               Write-output(" Granting access policies to objectId " + $ServicePrincipalId + " ...")
               $output = $null;
               $output = Set-AzureRmKeyVaultAccessPolicy -BypassObjectIdValidation -VaultName $KeyVault.VaultName -ObjectId $ServicePrincipalId -PermissionsToKeys 'list' -PermissionsToSecrets 'list'
                
                   if(!$output)
                   {
                       Write-output(" " + $KeyVault.VaultName + "Access policies granted successfully for objectId " + $ServicePrincipalId)  
                   } else {
                       Write-output("Failed to grant access policies to objectId " + $ServicePrincipalId)
                   }

           #Optional - print the updated key vault object access policies
           #$CurrentKeyvault = Get-AzureRMKeyVault -VaultName $KeyVault.VaultName
           #Write-output($CurrentKeyvault.AccessPoliciesText)

           Write-output(" Finshied handling key vault " + $KeyVault.VaultName)
   }
   catch {
       Write-output("Failed to set permissions for KeyVault " + $KeyVault.VaultName)
       Write-Error -Message $_.Exception
       throw $_.Exception
   }
}
