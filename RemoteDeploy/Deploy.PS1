
$computerName = "10.0.0.9"

$securePassword = ConvertTo-SecureString "password" -AsPlainText -force
$Credential = New-Object System.Management.Automation.PsCredential("10.0.0.9\user",$securePassword)

. ./RemoteDeploy

<#

1. Copy new versions to target machine
2. Stop services
3. Create backup of existing services
4. Deploy new files
5. Start services

#>
