################################
#    Adamj Password Expiry     #
#         Notification         #
#         Version 1.0          #
#                              #
#     Original Script by:      #
#    Author: Matt Bergeron     #
#   Company: Whidbey Telecom   #
#    SpiceWorks: Chamele0n     #
#                              #
#  Modified By: Adam Marshall  #
#     http://www.adamj.org     #
# http://www.helpingteens.org  #
################################

################################
#         Instructions         #
################################

<#
The purpose of this script is to email all users that their password is about to expire
days before the password expires. It is also to give them the various instructions on how
to change their password in various environments (Like working away from the office on a
domain-connected laptop).

Requirements: Active Directory module - installed with RSAT.

Edit the variables below to match your environment. Create a scheduled task to run it daily
at the time you wish. The action of the scheduled task should have the "Program/script"
field as the path to PowerShell on that server.
eg: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
The arguments line should have "-ExecutionPolicy Bypass " and then the path to this script.
eg: -ExecutionPolicy Bypass C:\Scripts\Email-PasswordExpiry.ps1
#>
################################
#           Variables          #
################################

# Email account to send the email from
$From = "itsupport@insightsoftware.com"

# Mail server to send the email from
$SMTPServer = "smtp.office365.com:587"

# Subject of the email
$MailSubject = "Windows Password Reminder: Your password will expire soon."

# Number of days before password expires to start sending the emails
$DaysBeforeExpiry = "7"

# Maximum password age - Maximum amount of days until a password expires. This is an optional variable, if this is left commented,
# the script will find the maximum password age from the group policy's password policy.
#$maxPasswordAge = '90'


# Do you wish to setup this script for testing? (Yes/No)
$SetupForTesting = "Yes"
# What username do you wish to test with?
$TestingUsername = "username"


################################
# Don't modify below this line #
################################

### Attempts to Import ActiveDirectory Module. Produces error if fails.

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Host "Unable to load Active Directory module, is RSAT installed?"; Break }

### Set the maximum password age based on group policy if not supplied in parameters.

if ($maxPasswordAge -eq $null) {
	$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
}

if ($SetupForTesting -eq "Yes") {
    $CommandToGetInfoFromAD = Get-ADUser -Identity $TestingUsername -properties PasswordLastSet, PasswordExpired, PasswordNeverExpires, EmailAddress, GivenName
    Clear-Variable DaysBeforeExpiry
    $DaysBeforeExpiry = "1000"
} else {
    $CommandToGetInfoFromAD = Get-ADUser -filter * -properties PasswordLastSet, PasswordExpired, PasswordNeverExpires, EmailAddress, GivenName
}

#Run the command to get information from Active Directory
$CommandToGetInfoFromAD | ForEach {
	$Today = (Get-Date)
	$UserName = $_.GivenName
 	if (!$_.PasswordExpired -and !$_.PasswordNeverExpires) {
 		$ExpiryDate = ($_.PasswordLastSet+$maxPasswordAge)
        $ExpiryDateForEmail = $ExpiryDate.ToString("dddd, MMMM dd yyyy a\t hh:mm tt")
		$DaysLeft = ($ExpiryDate-$Today).days
		if ($DaysLeft -lt $DaysBeforeExpiry -and $DaysLeft -gt 0) {
		    	$MailProperties = @{
			    	From = $From
				    To = $_.EmailAddress
				    Subject = $MailSubject
				    SMTPServer = $SMTPServer
			    }
			### Message Body for email
			$MsgBody = @"
<p>$UserName,</p>
<p>Your Windows password expires on $ExpiryDateForEmail. You have $DaysLeft days left before your password expires. 
Please change your password <span style="font-weight: bold; color: red;">before</span> it expires to prevent
an interruption of services (files, computers, printers, email, etc).</p>
<p><span style="font-weight: bold; font-size: 1.2em;">To change your password:</span><br>
Please change your Windows password by pressing CTRL+ALT+DEL and selecting "Change a Password".</p>
<p><span style="font-weight: bold; font-size: 1.2em;">Are you out of the office?:</span><br>
For those people who are out of the office, please make sure you are connected to the VPN when you try to change 
your password, or you won't be able to change it. Please then Lock your computer (CTRL+ALT+DEL &gt; Lock this 
computer), and unlock it with your new password. This will force Windows to check with the domain controller and 
pull down your latest Ticket that grants you access to resources.</p>
<p><span style="font-weight: bold; font-size: 1.2em;">Do you have a Mobile Phone with your email on it?:</span><br>
After you change your password, if you have a mobile phone with your email on it, you will need to update the 
password on your phone to continue to receive emails.</p>
<p>IT Department<br>
InsightSoftware <br>
<a href="mailto:email@domain.com">email@domain.com</a></p>
"@

			### Sends email to user with the message in $MsgBody variable and the supplied @MailProperties.
			Send-MailMessage @MailProperties -body $MsgBody -BodyAsHtml
		}
	}	  
}

<#
Version Notes:
1.0 - Intial Release - Made changes to original script to add a better message, allow html, create a testing
      section, setup a changable variable for days before expiry.
#>
# EOF