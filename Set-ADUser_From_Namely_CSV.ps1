##  This file is intended to import a csv from Namely's Employee Directory
##  Then update ADUser Properties with attributes from Namely using the Set-ADUser cmdlet
##  At Import the script converts the headers from the Namely Export to usable headers for Active Directory
##  Then creates variables for the new headers
##  Then cross references the directory to verify users from the CSV exist within the directory 
##  Then sets attributes for ADUsers imported from Namely
##  Written by Jonathan Joyner
##  4-29-2020
##  InsightSoftware
[Array]$UserData = import-csv NamelyTestCSV.csv | select-object {
    @{n="Full Name";e={$_.DisplayName}},
    @{n="Job Title";e={$_.Title}},
    @{n="Office Phone";e={$_.OfficePhone}},
    @{n="Office Address Location Address 1";e={$_.StreetAddress1}},
    @{n="Office Address Location Address 2";e={$_.StreetAddress2}},
    @{n="Office Address Location City";e={$_.City}},
    @{n="Office Address Location Zip";e={$_.PostalCode}},
    @{n="Office Address Location State ID";e={$_.State}},
    @{n="Office Address Country Name";e={$_.Country}},
    @{n="Office Location";e={$_.Office}},
    @{n="Company email";e={$_.UserPrincipalName}}
}
ForEach-object {
    $DisplayName = $_.DisplayName
    $Title = $_.Title
    $OfficePhone = $_.OfficePhone
    $StreetAddress1 = $_.StreetAddress1
    $StreetAddress2 = $_.StreetAddress2
    $StreetAddress = $StreetAddress1 + $StreetAddress2
    $City = $_.City
    $PostalCode = $_.PostalCode
    $State = $_.State
    $Country = $_.Country
    $Office = $_.Office
}
ForEach-Object {$User in $UserData}{
    $ADUserExists = Get-ADUser -Identity $User.UserPrincipalName
    If($ADUserExists){
        Write-Host "Updating attributes for" $User.DisplayName
        Set-ADUser -Identity $User.UserPrincipalName -DisplayName $DisplayName -Title $Title -OfficePhone $OfficePhone -StreetAddress $StreetAddress -City $City -PostalCode $PostalCode -State $State -Country $Country -Office $Office
        Start-Sleep 1
    }
    Else {
        Write-Host "The ADUser for" $User.DisplayName "doesn't exist"
    }
}
