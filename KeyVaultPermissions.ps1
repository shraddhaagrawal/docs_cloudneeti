$connectionName = "AzureRunAsConnection"
try
{

   # Get the connection "AzureRunAsConnection "
   $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName 
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
Write-output("Getting Variable value for Service Principal Id")
try
{
  $ServicePrincipalId = Get-AutomationVariable -Name "ServicePrincipalId"
  if($ServicePrincipalId -eq $null)
  {
      Write-output("Failed to get service principal Id variable")
      Exit
  }
}
catch
{
   Write-output("Failed to get service principal Id")
   Write-Error -Message $_.Exception
   throw $_.Exception
}



try
{
   Write-output("Getting list of key vaults")
   $KeyVaults = Get-AzureRmKeyVault
} catch {
   Write-output("Failed to list KeyVaults")
   Write-Error -Message $_.Exception
   throw $_.Exception
}


foreach($KeyVault in $KeyVaults)
{
   try
   {   
               Write-output(" Granting list access policies to service principal " + $ServicePrincipalId + " On Key Vault " + $KeyVault.VaultName)
               $output = $null;
               $output = Set-AzureRmKeyVaultAccessPolicy -BypassObjectIdValidation -VaultName $KeyVault.VaultName -ObjectId $ServicePrincipalId -PermissionsToKeys 'list' -PermissionsToSecrets 'list'
                
                   if(!$output)
                   {
                       Write-output("Access policies granted successfully to service principal " + $ServicePrincipalId + " On Key Vault " + $KeyVault.VaultName)  
                   } else {
                       Write-output("Failed to set permissions for KeyVault " + $KeyVault.VaultName)
                   }
   }
   catch {
       Write-output("Failed to set permissions for KeyVault " + $KeyVault.VaultName)
       Write-Error -Message $_.Exception
       throw $_.Exception
   }
}

Write-output("Script execution completed")
