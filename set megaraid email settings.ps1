#Configures the MegaRAID Storage Manager on specified servers to send email for Critical & fatal alerts.

$hosts = Get-Content C:\users\lgaudreau\Documents\temp-servers.txt # Get-SCVMHost | Select-Object -ExpandProperty ComputerName   # - example.  Can accept array of computer names like 'Get-SCVMHost | Select-Object ComputerName'

foreach ($comp in $hosts) {  # Master For
	
    $comp = $($comp).ToUpper()
	
    $path = "\\$($comp)\c`$\Program Files (x86)\MegaRAID Storage Manager\MegaMonitor\config-current.xml"
	
    if (Test-Path $path) { # Test-Path If

        $sender = "$comp@mail.com"
        $servername = "smtp.mail.com"
        $recipient = "hardwarwealert@mail.com"

        [string]$ipaddress = (Test-Connection $comp -Count 2).IPV4Address.IPAddressToString[0]
	

        $MSMXML = (Select-Xml -Path $path -XPath /).Node

        #Set email
        $MSMXML.'monitor-config'.actions.email.nic = $ipaddress
        $MSMXML.'monitor-config'.actions.email.sender = $sender
        $MSMXML.'monitor-config'.actions.email.'email-target' = $recipient
        $MSMXML.'monitor-config'.actions.email.servername = $servername
        $MSMXML.'monitor-config'.actions.email.'authentication-type' = "none"

        #If critical alerts have not been set to email, add email
        $SetAlert = $MSMXML.'monitor-config'.global.severity.Item(1)

        if (!($SetAlert.ChildNodes.ToString() -like "*do-email*")) {
	
            $attrib = $SetAlert.OwnerDocument.CreateElement("do-email")
            $SetAlert.AppendChild($attrib)
	
        }

        $MSMXML.Save($path) # Save changes

        
        #$MSMXML_Verify = (Select-Xml -Path $path -XPath /).Node #Read file to verify changes

        "$comp complete"
	
		<#
        Write-Output "Sender: "$MSMXML_Verify.'monitor-config'.actions.email.sender""
    	Write-Output "Recipient: "$MSMXML_Verify.'monitor-config'.actions.email.'email-target'""
    	Write-Output "IP address: "$MSMXML_Verify.'monitor-config'.actions.email.nic""
    	Write-Output "Mail Server: "$MSMXML_Verify.'monitor-config'.actions.email.servername""
    	Write-Output "Server Authentication: "$MSMXML_Verify.'monitor-config'.actions.email.'authentication-type'""
		#>
	
    } # End Test-Path If

    else {Write-Output "MegaRAID Storage Manager not installed on $comp"}

} # End Master For
