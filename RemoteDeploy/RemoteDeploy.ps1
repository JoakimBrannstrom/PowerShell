
<#
$RunSimulation = $true
$Verbose = $true
$FileTypesToRemove = @('*.dll', '*.pdb', '*.xml')
$FolderNamesToInclude = @('bin', 'obj')
$FolderNamesToIgnore = @('packages', '_tools$', '_build')
#$BasePath = (Get-Location -PSProvider FileSystem).ProviderPath
#$BasePath = "D:\"
#>


$computerName = "10.0.0.9"
$securePassword = ConvertTo-SecureString "password" -AsPlainText -force
$Credential = New-Object System.Management.Automation.PsCredential("domain\username",$securePassword)



#$service = Get-Service -ComputerName 10.0.0.9
# [System.Management.Automation.PSCredential]$Credential = $null
if (!($Credential))
{
	#prompt for user credential
	$Credential = get-credential -credential Domain\username
}

$scriptblock = {
        param ( $ServiceName, $Control )

        $Services = Get-Service -Name $ServiceName
        if ($Services)
        {
            switch ($Control) {
                "Start" { $Services | Start-Service }
                "Stop"  { $Services | Stop-Service }
            }
        }
        else
        {
            write-error "No service found!"
        }
    }

    # Invoke-Command -ComputerName $computerName -Authentication Kerberos -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $ServiceName, $Control
    # Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $ServiceName, $Control
	# Invoke-Command -ComputerName 10.0.0.9 -Credential $Credential -ScriptBlock {Get-Process}

	# http://technet.microsoft.com/en-us/library/dd819505.aspx
	# enter-pssession 10.0.0.9

	$session = new-pssession -Credential $Credential -computername 10.0.0.9
	# $session = Enter-PSSession -Credential $Credential -computername 10.0.0.9
	invoke-command -session $session {
		hostname
		get-service -Name service1
		get-service -Name service2
	}
	exit-pssession


# Set-ExecutionPolicy Unrestricted
# Set-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1
# set-item WSMan:\localhost\Client\TrustedHosts -value <Remote-computer-name>

# Enable-PSRemoting –force
# winrm quickconfig
# winrm set winrm/config/client @{TrustedHosts="RemoteComputerName"}
# winrm set winrm/config/client @{TrustedHosts="10.0.0.200"}
# set-item WSMan:\localhost\service\AllowUnencrypted $true
# Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
# New-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1
# Set-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1

# http://www.admin-magazine.com/Articles/PowerShell-Part-2-Manipulating-Services-Processes-and-Commands
# http://social.technet.microsoft.com/Forums/windowsserver/en-US/5cb68d61-ceb7-4086-9a07-d20b14131b21/how-to-add-winrm-trusted-host-in-windows-2008-server?forum=winservergen
# http://technet.microsoft.com/en-us/magazine/ff700227.aspx
# http://stackoverflow.com/questions/1469791/powershell-v2-remoting-how-do-you-enable-unencrypted-traffic
# http://hardforum.com/archive/index.php/t-1585390.html
