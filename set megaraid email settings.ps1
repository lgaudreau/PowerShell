#Configures the MegaRAID Storage Manager on specified servers to send email for Critical & fatal alerts.

$hosts = "host" #Get-SCVMHost | select ComputerName # - example.  Command can do array of computer names

foreach ($comp in $hosts) {

$comp = $($comp).ToUpper()

$path = "\\$($comp)\c`$\Program Files (x86)\MegaRAID Storage Manager\MegaMonitor\config-current.xml"

$sender = "$comp@sender.com"
$servername = "mailserver.sender.com" 
$recipient = "recipient@sender.com"

$MSMXML = ( Select-Xml -Path $path -XPath / ).Node

#Set email
$MSMXML.'monitor-config'.actions.email.sender = $sender
$MSMXML.'monitor-config'.actions.email.'email-target' = $recipient
$MSMXML.'monitor-config'.actions.email.servername = $servername

#If critical alerts have not been set to email, add email
$SetAlert = $MSMXML.'monitor-config'.global.severity.Item(1)

if(!($SetAlert.ChildNodes.ToString() -like "*do-email*")) {

$attrib = $SetAlert.OwnerDocument.CreateElement("do-email")
$SetAlert.AppendChild($attrib)

}

$MSMXML.Save($path) # Save changes

$MSMXML_Verify = ( Select-Xml -Path $path -XPath / ).Node #Read file to verify changes

$comp
write-output "Sender: "$MSMXML_Verify.'monitor-config'.actions.email.sender""
write-output "Recipient: "$MSMXML_Verify.'monitor-config'.actions.email.'email-target'""

}
