#####   This script is intended to Export the memberships of all Groups in AD
#####   Actions: 
#####       Get array of all ADGroups
#####       Export CSV of Group's Members
#####   To run this script update Line "13" with the path of the csv
#####   Before Running Verify "C:\Exports\AD\Groups\" exists
#####   Created on 4/13/21 for Insightsoftware by Jonathan Joyner
Import-Module ActiveDirectory
$Groups = Get-ADGroup -Filter *
    foreach($Group in $Groups){
    $GroupName = $Group.Name
    $GroupExists = Get-ADGroup -Identity $GroupName
        If($GroupExists){
        Write-Host "Exporting ADGroup Members for Group:" $GroupName
        Get-ADGroupMember -Identity $GroupName | export-CSV C:\Exports\AD\Groups\Built-inGroups\$GroupName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1
        }
        Else {
        Write-Host "Group" $GroupName "Does not exist"
        Start-Sleep 1
    }
}