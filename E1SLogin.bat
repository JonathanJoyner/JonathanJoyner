### Purpose of this script is to delete all mapped drives at login
### After the previously mapped drives are deleted a group policy update is forced to map the new drive locations
### Created By: Jonathan Joyner
### Created For: Insightsoftware
### Created On: 2/14/21
{
    Timeout 30
!
    Net Use * /del /y
!
    Timeout 30
!
    Gpupdate /force
}