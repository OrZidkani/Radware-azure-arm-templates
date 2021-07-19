######### Written by Or Zidkani ################
# Set the Execution policy for "RemoteSigned" in order to launch the script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Install Azure resource manager cmdlet
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name az -AllowClobber

try {
    Get-AzSubscription | Out-Null
    Write-Host "Already logged in"
    }
    catch {
      Write-Host "Not logged in, transfering to login page"
      Connect-AzAccount
    }




$SubIdCount =  Get-AzSubscription| Measure-Object -Line
$Subid = Get-AzSubscription
 If ($SubIdCount.lines  -eq '1')  {

  $Subid = Get-AzSubscription

  } Else {

    $linenumber = 1
$Subid |
   ForEach-Object {New-Object psObject -Property @{'Subscription ID'= $_.id;};$linenumber ++ } -outvariable choosemenu | out-null
    
function Show-Menu
{
    param (
        [string]$Title = 'Subscription Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    $Menu = @{}

    $choosemenu -replace '@.*ID=' -replace '}' | ForEach-Object -Begin {$i = 1} { 
        Write-Host " $i. $_`  " 
        $Menu.add("$i",$_)
        $i++
    }

    Write-Host "Q: Press 'Q' to quit."

    $SubSelection = Read-Host "Please make a selection"

    if ($SubSelection -eq 'Q') { Return } Else { $Menu.$SubSelection }

}
$UserSelection = Show-Menu -Title 'Subscription Choose'
Write-Host "Choosen subscription: $UserSelection

"
}




$SubscriptionId = $UserSelection
$DisplayName = Read-Host "Please specify DisplayName (For example: "radware-cluster" )"
$HomePage =  Read-Host "Please specify HomePage (For example: "https:/localhost/radware-cluster" )"
$IdentifierUris = Read-Host "Please specify Identifier URL (For example: "https:/localhost/radware-cluster" )"
$ClientSecret = Read-Host 'Please specify Client Password (It will be necesary later)' -AsSecureString


$AzureSubscriptionId = Get-AzSubscription -SubscriptionId $SubscriptionId
$AppReg = New-AzADApplication -DisplayName $DisplayName -HomePage $HomePage -IdentifierUris  $IdentifierUris -Password $ClientSecret
$ClientID = $AppReg.ApplicationId.Guid
New-AzADServicePrincipal -ApplicationId $ClientID
Write-Output 'Waiting for ClientID registration'
Start-Sleep -Seconds 30 | out-null
New-AzRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $ClientID
Write-Output @{ "Client ID" = $ClientID; "Tenant ID" = $AzureSubscriptionId.TenantID; "Subscription Name" = $AzureSubscriptionId.Name; "AppID" = $AppReg.DisplayName; }
Write-Output 'Please save those parmateres '

Read-Host "Press Q to close the window"

