Import-Module ActiveDirectory

$Domain="@insightsoftware.com"

$UserOu="OU=LogiAnalytics,OU=Emails,OU=insightsoftware,DC=insightsoftware,DC=lan"

$NewUsersList=Import-CSV "C:\Users\admin.jonathan\Documents\LogiADImportTest.csv"

ForEach ($User in $NewUsersList) {

    $FullName=$User.Name

    $givenName=$User.GivenName

    $Title=$User.Title

    $SamAccountName=$User.SamAccountName

    $Surname=$User.surname

    $UserPrincipalName=$User.UserPrincipalName

    $Company=$User.Company

    $Department=$User.Department

    $Country=$User.Country

    $Description=$User.Description

    $userPassword=$User.Password

    $expire=$null

New-ADUser -PassThru -Path $UserOu -Enabled $True -ChangePasswordAtLogon $True -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -Force) -CannotChangePassword $False –Title $Title -DisplayName $FullName -GivenName $givenName -Name $FullName -SamAccountName $SamAccountName -Surname $Surname -UserPrincipalName $UserPrincipalName -EMail $UserPrincipalName -Company $Company -Department $Department -Country $Country -Description $Description

}