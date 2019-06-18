$connectionName = "AzureRunAsConnection"
try
{

   # Get the connection "AzureRunAsConnection"
   $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName 
   Write-Host("Logging in to Azure using $connectionName");
   Add-AzureRmAccount -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -ApplicationId $servicePrincipalConnection.ApplicationId -TenantId $servicePrincipalConnection.TenantId
}
catch{
   if (!$servicePrincipalConnection)
   {
       $ErrorMessage = "Connection $connectionName not found."
       throw $ErrorMessage
   } else{
       Write-Host -Message $_.Exception -ForegroundColor Red
       throw $_.Exception
   }
}

Write-Host("Login to Azure Successful.")

#specify Applications object id to grant access policies to
$ServicePrincipalId = Get-AutomationVariable -Name "ServicePrincipalId"


try
{
   #List all the subscription key vaults...
   Write-Host(" Listing key vaults...") -ForegroundColor Yellow
   $KeyVaults = Get-AzureRmKeyVaults
} catch {
   Write-Host("Failed to list KeyVaults:") -ForegroundColor Red
   Write-Host -Message $_.Exception -ForegroundColor Red
   throw $_.Exception
}


# Iterate all key vaults found
foreach($KeyVault in $KeyVaults)
{
   try
   {   
               Write-Host(" Granting list access policies to service principal " + $ServicePrincipalId + "On Key Vault" + $KeyVault.Name) -ForegroundColor Yellow
               $output = $null;
               $output = Set-AzureRmKeyVaultAccessPolicy -BypassObjectIdValidation -VaultName $KeyVault.VaultName -ObjectId $ServicePrincipalId -PermissionsToKeys 'list' -PermissionsToSecrets 'list'
                
                   if(!$output)
                   {
                       Write-Host(" " + $KeyVault.VaultName + "Access policies granted successfully to service principal " + $ServicePrincipalId)  -ForegroundColor Green
                   } else {
                       Write-Host("Failed to grant access policies to to service principal " + $ServicePrincipalId) -ForegroundColor Red
                   }
   }
   catch {
       Write-Host("Failed to set permissions for KeyVault " + $KeyVault.VaultName) -ForegroundColor Red
       Write-Host -Message $_.Exception -ForegroundColor Red
       throw $_.Exception
   }
}
