    <#
        .SYNOPSIS
            Check for computer description in Active Directory and Computer Properties
        .DESCRIPTION
            Check for computer description in Active Directory and Computer Properties
        .PARAMETER ComputerName
            The NetBIOS or FQDN of the computer
		.PARAMETER
            Check VMM for description.  Slower, so not checked by default
        .EXAMPLE
            Get-OS -ComputerName 
        .NOTES
            LGaudreau May 2018
    #>

Function Get-OS
{

    [CmdletBinding()]
    Param
        (
        [string]$ComputerName,
        [switch]$VMM
	)
    Begin
 
   {



## Active Directory

if ($Details = Get-ADComputer $ComputerName -Properties Description,OperatingSystem,OperatingSystemVersion) {

    If (Test-Connection $ComputerName -count 1 -Quiet) {


    if ($details.OperatingSystemVersion -lt 6.2) { # Will use WMI instead of CIM if computer is older than Windows 2012
        
        $OSValues = Get-WmiObject -ClassName Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $ComputerName 
     
    }

    else {

    $OSValues = Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $ComputerName | select Caption,Description 
}

} #if test-connection

## Virtual Machine Manager

  if ($VMM) {
  $VMMDesc = Get-SCVirtualMachine $ComputerName | select Description 
  
  $properties = [ordered]@{'Name'= $ComputerName;
                '      '=$null
                'AD_OperatingSystem'=$Details.OperatingSystem;
                'AD_Description'=$Details.Description;
                'AD_Enabled'=$Details.Enabled;
                'AD_DistinguishedName'=$Details.DistinguishedName;
                '   '=$null
                'OS_OperatingSystem'=$OSValues.Caption;
                'OS_Description'=$OSValues.Description;
                ' '=$null
                'VMM_Description' = $VMMDesc.Description
                }
            }

        else { $properties = [ordered]@{
                'Name'= $ComputerName;
                '   '=$null
                'AD_OperatingSystem'=$Details.OperatingSystem;
                'AD_Description'=$Details.Description;
                'AD_Enabled'=$Details.Enabled;
                'AD_DistinguishedName'=$Details.DistinguishedName;
                ' '=$null
                'OS_OperatingSystem'=$OSValues.Caption;
                'OS_Description'=$OSValues.Description;
                        }                   

                    } #If VMM

## Put it all together and output   
	$object = New-Object -TypeName psobject -Prop $properties
    $object

} #If details real


  
  }
} # end function
