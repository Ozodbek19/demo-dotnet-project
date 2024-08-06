# Set variables
$siteName = "demoapp"
$appPoolName = "demoapppool"
$physicalPath = "C:\inetpub\wwwroot\demoapp"



New-WebAppPool -Name $appPoolName
Set-ItemProperty IIS:\AppPools\$appPoolName -name "managedRuntimeVersion" -value "v4.0"

New-Website -Name $siteName -PhysicalPath $physicalPath -ApplicationPool $appPoolName -Force

New-WebBinding -Name $siteName -IPAddress "*" -Port 80 -Protocol http



# Set permissions for the app pool to access the website directory
$acl = Get-Acl $physicalPath
$aclRuleArgs = "IIS AppPool\$appPoolName", "ReadAndExecute, Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclRuleArgs)
$acl.SetAccessRule($accessRule)
Set-Acl $physicalPath $acl

# Enable directory browsing (optional, for troubleshooting)
Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse -Name enabled -Value $true -PSPath "IIS:\Sites\$siteName"

# Start the website
Start-Website -Name $siteName

Write-Host "IIS configuration complete. Website '$siteName' is set up and running."