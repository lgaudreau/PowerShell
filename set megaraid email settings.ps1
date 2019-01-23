#Configures the MegaRAID Storage Manager on specified servers to send email for Critical & fatal alerts.

$hosts = "ServerName"  # - example.  Can accept array of computer names like 'Get-SCVMHost | select ComputerName'

foreach ($comp in $hosts) {
	
    $comp = $($comp).ToUpper()
	
    $path = "\\$($comp)\c`$\Program Files (x86)\MegaRAID Storage Manager\MegaMonitor\config-current.xml"
	
    $sender = "$comp@myfrhi.com"
    $servername = "torsmtp.myfairmont.com"
    $recipient = "fhr.dcalert.dl@frhi.com"

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

    $MSMXML_Verify = (Select-Xml -Path $path -XPath /).Node #Read file to verify changes

    $comp
    write-output "Sender: "$MSMXML_Verify.'monitor-config'.actions.email.sender""
    write-output "Recipient: "$MSMXML_Verify.'monitor-config'.actions.email.'email-target'""

}
