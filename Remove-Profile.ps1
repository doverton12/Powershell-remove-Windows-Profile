param([Parameter(Mandatory=$true, HelpMessage ="Enter the username to match. Please note this will not be wildcard matched by default" )]$username,
$prompt=$true,
$wildcard=$false,
[switch]$force)

if ($wildcard) {
   Write-Output "Username will be wildcard matched"
   $response = Get-WmiObject -Class Win32_UserProfile -filter "LocalPath like '%$username%'"
} else {
   $response = Get-WmiObject -Class Win32_UserProfile -filter "LocalPath like '%\\$username'"
}

if ($response -eq $null) {
   Write-Output "No profiles found that match"
   return
}

Write-Output "Profiles found"
$response | select localpath
if ($response.count -ne $null) {
   Write-Output "Too many accounts retruned. Narrow down and repeat"
   return
}
$UserID = (New-Object System.Security.Principal.SecurityIdentifier($response.SID)).Translate([System.Security.Principal.NTAccount])
Write-Host "Resolved user name: " $UserID.Value

if ($prompt) {
   $userresponse=Read-Host -Prompt "Press Y to proceed "
} else {
   $userresponse="Y"
}
 
if ($userresponse.ToLower() -eq "y") {
   if ($force.IsPresent -eq $false) {
       $userresponse = Read-Host -Prompt "Are you really sure? Press Y to proceed "
   } else {
       $userresponse="Y"
   }

   if ($userresponse.ToLower() -eq "y") {
       Write-Output "Removing users"
       $response | Remove-WmiObject
   } else {
       Write-Output "you chose not to remove the user"
   }
} else {
   Write-Output "You did not enter Y, so no action taken"
}
