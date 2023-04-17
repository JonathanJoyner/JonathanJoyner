#####   This script is intended to perform the AD related termination tasks
#####   Actions: 
#####       Update user's Password
#####       Update user's Expiry Date       
#####       Export CSV of user's Group Memberships
#####       Remove user's AD Group Memberships
#####   CSV Headers: DisplayName,SamAccountName,Password
#####   To run this script update Line "13" with the path of the csv
#####   Before Running Verify "C:\Exports\Terminations\" exists
#####   Created on 7/30/21 for Insightsoftware by Jonathan Joyner
#####
#####  This file is intended to connect the appropriate services from a remote shell to process it's intended function.
#####  Then dumps the contents of specified .csv into the container "MBUsers".
#####  Individual mailboxes are specified in the variable "MBUser" and verified against the database in new container "MailboxExists"
#####  Actions:
#####    1 - Exports AzureAD Group memberships to 'C:\Exports\Terminations\Office365\$UserName.csv'
#####    2 - Removes AzureAD Group memberships 
#####    3 - Converts recipienttype from usermailbox to sharedmailbox.
#####           Outputs text "Converting mailbox for %DisplayName%"
#####    4 - Removes the specified Office 365 AccountSkuID (License). Syntax: (Account:SkuID) Account: insightsw
#####           Outputs text "Removing license for %DisplayName%"
#####    5 - Disables Exchange ActiveSync
#####  If the intended target from the .csv is not verified to within "MailboxExists" generates output
#####    Outputs text "The mailbox for %DisplayName% doesn't exist"
#####  Per Scenario the following Line items should be updated:
#####       Line 25 - Update the filename and path       
#####       Line 45 - Update the type of mailbox conversion to be performed "Regular" or "Shared"
#####  This script requires the local path: 'C:\Exports\Terminations\Office365'
#####   Created on 5/24/21 for Insightsoftware by Jonathan Joyner
#####
###   Install and Connect necesary Services, Set necessary preferences
Import-Module ActiveDirectory
Install-Module AzureAD
Install-Module MSOnline
Connect-MSolService
Connect-ExchangeOnline
Connect-AzureAD
$ErrorActionPreference = "Continue"
###  Setup for Logs and UNC Paths
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Office365'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
###   Import Data and Start AD Procedures
Write-Host "Proceeding with Active Directory Termination Procedures"
$Leavers = Import-Csv -Path "C:\Exports\TestTermination.csv"
    foreach($Leaver in $Leavers){
    $UserName = $Leaver.SamAccountName
    $UserDisplayName = $Leaver.DisplayName
    $Password = $Leaver.Password
    $ExpiryDate = (Get-date).AddDays(90)
    ###   Verify user exists
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        ###   Forced Password reset on user
            Write-Host "Updating Password for user:" $UserDisplayName
            Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
            Start-Sleep 1
        ###   Set Account Expiry 
            Write-Host "Updating Expiry for user:" $UserDisplayName "to" $ExpiryDate
            Set-ADUser -Identity $UserName -AccountExpirationDate $ExpiryDate
            Start-Sleep 1
        ###   Export AD Group Memberships to CSV
            Write-Host "Exporting ADGroup Memberships for user:" $UserDisplayName
            Get-ADPrincipalGroupMembership -Identity $UserName | Select-Object name, groupcategory, groupscope | export-CSV C:\Exports\Terminations\$UserName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
            Start-Sleep 1
        ###   Remove all AD Group Memberships
            Write-Host "Removing ADGroup Memberships for user:" $UserDisplayName
            Get-AdPrincipalGroupMembership -Identity $Username | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Username -Confirm:$false
            Start-Sleep 1
        }
        Else {
        ###   Report users with Error for log file
            Write-Host "User" $UserName "Does not exist"
            Start-Sleep 1
        }
}
###   Synchronize Domain Controllers
Write-Host "Synchronizing Domain Controllers"
Repadmin /SYNCALL
Start-Sleep 10
###   Forced Sync to Office 365
Write-Host "Syncing to Office 365"
Start-AdSyncSyncCycle -Policytype Delta
Start-Sleep 30
###   Start Office 365 Termination Procedures
Write-Host "Proceeding with Office 365 Termination Procedures"
$GroupName = @()
$UserObjectID = @()
$MsolLicense = @()
foreach ($Leaver in $Leavers){
    $UserDisplayName = $MBUser.DisplayName
    $UserName = $MBUser.UserPrincipalName
    $ManagerDisplayName = $MBUsers.ManagedBy
    $Manager = $MBUser.Manager
    $OOO = $MBUsers.OOO
    ###   Verify that the mailbox exists
    $MailboxExists = Get-Mailbox -Identity $UserName
    If($MailboxExists){
    ###   Exports Group Memberships to 'C:\Exports\Terminations\Office365\$UserName.csv'
        Write-Host "Exporting AzureAD Group Memberships for user:" $UserDisplayName
        Get-AzureADUserMembership -ObjectId $UserName | Select-Object DisplayName | export-CSV C:\Exports\Terminations\Office365\$UserName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1
    ###   Gets an array of Group data that the user is a member of.
    ###   Gets an array of User data associated to the user. 
    ###   Removes user from AzureAD groups. Will 'Continue' after errors for "Externally Synced Groups".
        Write-Host "Removing AzureAD Group Memberships for user:" $UserDisplayName
        $GroupName = Get-AzureADUserMembership -ObjectId $Username
        $UserObjectID = Get-AzureADUser -Filter "userPrincipalName eq '$Username'" 
        foreach ($Group in $GroupName){
        Remove-AzureADGroupMember -ObjectID $Group.ObjectID -MemberId $UserObjectID.ObjectId 
        Start-Sleep 5
    }
    ###   Converts RecipientType to 'Shared'
        Write-Host "Converting mailbox for" $UserDisplayName "to Shared"
        Set-Mailbox -Identity $UserName -Type "Shared" -Verbose
        Start-Sleep 1
    ###   Gets an array of License data for the user. 
    ###   Removes the assigned licenses from the user. 
        Write-Host "Removing license for" $UserDisplayName
        $MsolLicense = (Get-MsolUser -UserPrincipalName $UserName).licenses
        Start-Sleep 1
        $MsolUserLicense = ($MSolLicense).AccountSkuID
        Set-MsolUserLicense -UserPrincipalName $UserName -RemoveLicenses $MsolUserLicense
        Start-Sleep 1
    ###   Disables Exchange ActiveSync for the user. 
        Write-Host "Disabling Exchange ActiveSync for" $UserDisplayName
        Set-CASMailbox -Identity $UserName -ActiveSyncEnabled $false
        Start-Sleep 1
    ###   Blocks user's Sing-in
        Write-Host "Blocking Sign-in for" $UserDisplayName
        Set-AzureADUser -ObjectID $UserName -AccountEnabled $false
        Start-Sleep 1
    ###   Delegates 'FullAccess' permission to manager. 
        Write-Host "Granting Manager" $ManagerDisplayName "Full Access to:" $UserDisplayName
        Add-MailboxPermission -Identity $UserName -User $Manager -AccessRights FullAccess -InheritanceType All -AutoMapping $true
        Start-Sleep 1
    ###   Enables and sets Out of Office message for user. 
        Write-Host "Setting OOO message for" $UserDisplayName "to" $OOO
        Set-MailboxAutoReplyConfiguration -Identity $UserName -AutoReplyState Enabled -InternalMessage $OOO -ExternalMessage $OOO
        Start-Sleep 1
        }
    Else {
    ###   Report users with Error for log file
        Write-Host "The mailbox for" $UserDisplayName "doesn't exist"
    }
}
Stop-Transcript