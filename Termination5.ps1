#####   This script is intended to perform the AD related termination tasks
#####   Actions: 
#####       Update user's Password
#####       Update user's Expiry Date       
#####       Export CSV of user's Group Memberships
#####       Remove user's AD Group Memberships
#####   CSV Headers: DisplayName,SamAccountName,Password
#####   To run this script update Line "16" with the path of the csv
#####   Created on 4/7/21 for Insightsoftware by Jonathan Joyner
#####       Updates - Disables instead of set to expire. Create transcript log. 8/11/21
#####       Updates - Moves user to specific disabled OU. 3/16/22
Import-Module ActiveDirectory
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\Terminations\Logs\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Logs'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
$Leavers = Import-Csv -Path "C:\Exports\Terminations\CSV\TestTermination.csv"
foreach($Leaver in $Leavers){
    $UPN = $Leaver.UserPrincipalName
    $User = Get-ADUser -Filter * | Where-Object {($_.UserPrincipalName -eq $UPN)} | Select-Object SamAccountName
    $UserName = $User.SamAccountName
    $UserDisplayName = $Leaver.DisplayName
    $Password = $Leaver.Password
    $ExpiryDate = (Get-date).AddDays(90)
    $DisabledDate = (Get-Date)
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Updated Password for user:" $UserDisplayName
        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
        Start-Sleep 1
        Write-Host "Disabled AD Account  for user:" $UserName "on" $DisabledDate
        Disable-ADAccount -Identity $Username
        Start-Sleep 1
        Write-Host "Exported ADGroup Memberships for user:" $UserDisplayName
        Get-ADPrincipalGroupMembership -Identity $UserName | Select-Object name, groupcategory, groupscope | export-CSV C:\Exports\Terminations\2022\$UserName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1
        Write-Host "Removed ADGroup Memberships for user:" $UserDisplayName
        Get-AdPrincipalGroupMembership -Identity $Username | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Username -Confirm:$false
        Start-Sleep 1
        Write-Host "Moving User:" $UserDisplayName "to Disabled OU"
        $UserOU = (Get-ADUser -Identity $UserName).DistinguishedName
            If( $UserOU -match 'OU=Accolite')
            {
            $AccoliteDOU = "OU=Disabled,OU=Accolite,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $AccoliteDOU
            }
            If( $UserOU -match 'OU=Antivia')
            {
            $AntiviaDOU = "OU=Disabled,OU=Antivia,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $AntiviaDOU
            }
            If( $UserOU -match 'OU=BizNetSoftware')
            {
            $BizNetSoftwareDOU = "OU=Disabled,OU=BizNetSoftware,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $BizNetSoftwareDOU
            }
            If( $UserOU -match 'OU=BizviewSystems')
            {
            $BizviewSystemsDOU = "OU=Disabled,OU=BizviewSystems,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $BizviewSystemsDOU
            }
            If( $UserOU -match 'OU=Calumo')
            {
            $CalumoDOU = "OU=Disabled,OU=Calumo,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $CalumoDOU
            }
            If( $UserOU -match 'OU=Certent')
            {
            $CertentDOU = "OU=Disabled,OU=Certent,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $CertentDOU
            }
            If( $UserOU -match 'OU=Claremont')
            {
            $ClaremontDOU = "OU=Disabled,OU=Claremont,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ClaremontDOU
            }
            If( $UserOU -match 'OU=Contractors')
            {
            $ContractorsDOU = "OU=Disabled,OU=Contractors,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ContractorsDOU
            }
            If( $UserOU -match 'OU=CXO Software')
            {
            $CXOSoftwareDOU = "OU=Disabled,OU=CXO Software,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $CXOSoftwareDOU
            }
            If( $UserOU -match 'OU=DynamicsBiAsia')
            {
            $DynamicsBiAsiaDOU = "OU=Disabled,OU=DynamicsBiAsia,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $DynamicsBiAsiaDOU
            }
            If( $UserOU -match 'OU=EastWingSolutions')
            {
            $EastWingSolutionsDOU = "OU=Disabled,OU=EastWingSolutions,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $EastWingSolutionsDOU
            }
            If( $UserOU -match 'OU=ELT')
            {
            $ELTDOU = "OU=Disabled,OU=ELT,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ELTDOU
            }
            If( $UserOU -match 'OU=Event1Software')
            {
            $Event1SoftwareDOU = "OU=Disabled,OU=Event1Software,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $Event1SoftwareDOU
            }
            If( $UserOU -match 'OU=Exago')
            {
            $ExagoDOU = "OU=Disabled,OU=Exago,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ExagoDOU
            }
            If( $UserOU -match 'OU=Excel4Apps')
            {
            $Excel4AppsDOU = "OU=Disabled,OU=Excel4Apps,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $Excel4AppsDOU
            }
            If( $UserOU -match 'OU=GlobalSoftware')
            {
            $GlobalSoftwareDOU = "OU=Disabled,OU=GlobalSoftware,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $GlobalSoftwareDOU
            }
            If( $UserOU -match 'OU=Hubble')
            {
            $HubbleDOU = "OU=Disabled,OU=Hubble,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $HubbleDOU
            }
            If( $UserOU -match 'OU=IDL')
            {
            $IDLDOU = "OU=Disabled,OU=IDL,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $IDLDOU
            }
            If( $UserOU -match 'OU=Isosceles')
            {
            $IsoscelesDOU = "OU=Disabled,OU=Isosceles,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $IsoscelesDOU
            }
            If( $UserOU -match 'OU=IT')
            {
            $ITDOU = "OU=Disabled,OU=IT,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ITDOU
            }
            If( $UserOU -match 'OU=iTransitions')
            {
            $iTransitionsDOU = "OU=Disabled,OU=iTransitions,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $iTransitionsDOU
            }
            If( $UserOU -match 'OU=JetGlobal')
            {
            $JetGlobalDOU = "OU=Disabled,OU=JetGlobal,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JetGlobalDOU
            }
            If( $UserOU -match 'OU=JV Benelux')
            {
            $JVBeneluxDOU = "OU=Disabled,OU=JV Benelux,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVBeneluxDOU
            }
            If( $UserOU -match 'OU=JV France')
            {
            $JVFranceDOU = "OU=Disabled,OU=JV France,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVFranceDOU
            }
            If( $UserOU -match 'OU=JV Italy')
            {
            $JVItalyDOU = "OU=Disabled,OU=JV Italy,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVItalyDOU
            }
            If( $UserOU -match 'OU=JV Middle East')
            {
            $JVMiddleEastDOU = "OU=Disabled,OU=JV Middle East,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVMiddleEastDOU
            }
            If( $UserOU -match 'OU=JV Nordics')
            {
            $JVNordicsDOU = "OU=Disabled,OU=JV Nordics,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVNordicsDOU
            }
            If( $UserOU -match 'OU=JV South Africa')
            {
            $JVSouthAfricaDOU = "OU=Disabled,OU=JV South Africa,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $JVSouthAfricaDOU
            }
            If( $UserOU -match 'OU=LogiAnalytics')
            {
            $LogiAnalyticsDOU = "OU=Disabled,OU=LogiAnalytics,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $LogiAnalyticsDOU
            }
            If( $UserOU -match 'OU=Longview')
            {
            $LongviewDOU = "OU=Disabled,OU=Longview,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $LongviewDOU
            }
            If( $UserOU -match 'OU=Magnitude')
            {
            $MagnitudeDOU = "OU=Disabled,OU=Magnitude,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $MagnitudeDOU
            }
            If( $UserOU -match 'OU=MekkoGraphics')
            {
            $MekkoGraphicsDOU = "OU=Disabled,OU=MekkoGraphics,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $MekkoGraphicsDOU
            }
            If( $UserOU -match 'OU=ST6 Partners')
            {
            $ST6PartnersDOU = "OU=Disabled,OU=ST6 Partners,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ST6PartnersDOU
            }
            If( $UserOU -match 'OU=TheAnalyticsCompany')
            {
            $TheAnalyticsCompanyDOU = "OU=Disabled,OU=TheAnalyticsCompany,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $TheAnalyticsCompanyDOU
            }
            If( $UserOU -match 'OU=Viareport')
            {
            $ViareportDOU = "OU=Disabled,OU=Viareport,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $ViareportDOU
            }
            If( $UserOU -match 'OU=XIBI')
            {
            $XIBIDOU = "OU=Disabled,OU=XIBI,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $XIBIDOU
            }
            If( $UserOU -match 'OU=insightsoftware,OU=Users,OU=insightsoftware')
            {
            $insightsoftwareDOU = "OU=Disabled,OU=insightsoftware,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
            Move-ADObject -Identity $UserOU -TargetPath $insightsoftwareDOU
            }
        }
        Else {
        Write-Host "User" $UserName "Does not exist"
        Start-Sleep 1
        }
}
repadmin.exe /syncall
Start-Sleep 1
Start-ADSyncSyncCycle -PolicyType Delta
Stop-Transcript