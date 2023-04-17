$GroupUsers = Import-csv C:\Users\admin.jonathan\Documents\Duo_VPN_Groups.csv
foreach ($GroupUser in $GroupUsers){
    $ADExists = Get-ADUser -Identity $Groupuser.SamAccountName
    If($ADExists){
        Write-Host "Adding to group for" $GroupUser.SamAccountName 
        Add-ADGroupMember -Identity $GroupUser.Name -Members $GroupUser.SamAccountName -Type "regular" -Verbose
        Start-Sleep 1
    }
    Else {
        Write-Host "User does not exist" $GroupUser.SamAccountName "doesn't exist"
    }
}