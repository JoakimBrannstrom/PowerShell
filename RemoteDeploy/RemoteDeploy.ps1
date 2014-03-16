
<#
$computerName = "192.168.1.2"
$securePassword = ConvertTo-SecureString "password" -AsPlainText -force
$Credential = New-Object System.Management.Automation.PsCredential("domain\username",$securePassword)
#>


# [System.Management.Automation.PSCredential]$Credential = $null
if (!($Credential))
{
	#prompt for user credential
	$Credential = Get-Credential -credential Domain\username
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

    # Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $ServiceName, $Control
	$session = new-pssession -Credential $Credential -computername $computerName
    # Invoke-Command -session $session -ScriptBlock $scriptBlock -ArgumentList $ServiceName, $Control
	invoke-command -session $session {
		hostname
		get-service -Name LinkBlog.Denormalizer
		get-service -Name LinkBlog.Server
		#get-service -Name service2
	}
	Remove-PSSession $Session


# Set-ExecutionPolicy Unrestricted
# Set-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1
# set-item WSMan:\localhost\Client\TrustedHosts -value <Remote-computer-name>

# Enable-PSRemoting –force
# winrm quickconfig
# winrm set winrm/config/client @{TrustedHosts="RemoteComputerName"}
# set-item WSMan:\localhost\service\AllowUnencrypted $true
# Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
# New-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1
# Set-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1

# http://www.admin-magazine.com/Articles/PowerShell-Part-2-Manipulating-Services-Processes-and-Commands
# http://social.technet.microsoft.com/Forums/windowsserver/en-US/5cb68d61-ceb7-4086-9a07-d20b14131b21/how-to-add-winrm-trusted-host-in-windows-2008-server?forum=winservergen
# http://technet.microsoft.com/en-us/magazine/ff700227.aspx
# http://stackoverflow.com/questions/1469791/powershell-v2-remoting-how-do-you-enable-unencrypted-traffic
# http://hardforum.com/archive/index.php/t-1585390.html
