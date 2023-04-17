Import-Module Active Directory
$ErrorActionPreference = "Continue"
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Office365'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$ADUsers = Import-csv $FilePath
foreach ($ADUser in $ADUsers){
    $FirstName = $ADUser.givenname
    $LastName = $ADUser.surname
    $DisplayName = $ADUsers.Name
    $UserName = (Get-ADUser * | Where-Object {($_.givenname -eq $FirstName) -and ($_.surname -eq $LastName)} | Select-Object SamAccountName).SamAccountName
    $ADUserExists = Get-ADUser -Identity $UserName
    If($ADUserExists){
        Write-Host "Getting User properties for" $DisplayName
        Get-ADUser -Identity $UserName | Select-Object DisplayName,givenname,surname,userPrincipalName,mail,proxyaddresses | export-CSV C:\Exports\LogiUsers050922.csv -Append -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1 
    }
    Else {
        Write-Host "The Account for" $DisplayName "doesn't exist"
    }
}
Stop-Transcript
