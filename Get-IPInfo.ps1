Function Get-IPInfo
{
    <#
        .SYNOPSIS
            Use WMIC to get IP information assigned to NICs
        .DESCRIPTION
            This function will return the IP information assigned to NICs and optionally MAC addresses without assigned IPs.
        .PARAMETER ComputerName
            The NetBIOS or FQDN of the computer
        .PARAMETER MACAddress
            Will return all network adapters with MAC addresses, including ones without IPs
        .EXAMPLE
            Get-IPInfo -ComputerName
    #>
    [CmdletBinding()]
    Param
        (
        $ComputerName,
        [switch] $MACAddress
	)


    Begin
    
 
   {

   $Results =@()


        # Check NIC name, IP address and DHCP
        #Write-Output "NIC Information (Only enabled NICs are displayed):"

        foreach ($Computer in $ComputerName) {

        if ($MACAddress) {
                            $NICs=get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | Where {$_.MACAddress -NE $NULL}
                            }

        else {
                $NICs=get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | Where {$_.IPEnabled -eq $TRUE}
             }

        Foreach($NIC in $NICs) {

        $index = $NIC.Index#[0]
        $adapter = Gwmi win32_networkadapter -ComputerName $Computer -Filter "index = $index"


              $NICDetails = New-Object System.Object

                            $NICDetails | Add-Member -Type NoteProperty -Name Name -Value $($Computer)
                            $NICDetails | Add-Member -Type NoteProperty -Name AdapterName -Value $($adapter.netconnectionid)
                            $NICDetails | Add-Member -Type NoteProperty -Name IPAddress -Value $($NIC.ipaddress)
                            $NICDetails | Add-Member -Type NoteProperty -Name SubnetMask -Value $($NIC.IPSubnet)
                            $NICDetails | Add-Member -Type NoteProperty -Name Gateway -Value $($NIC.DefaultIPGateway)
                            $NICDetails | Add-Member -Type NoteProperty -Name DNSServers -Value $($NIC.DNSServerSearchOrder)
                            $NICDetails | Add-Member -Type NoteProperty -Name MACAddress -Value $($NIC.MACAddress)
                            $NICDetails | Add-Member -Type NoteProperty -Name DHCPEnabled -Value $($NIC.dhcpenabled)

                            $Results += $NICDetails
 

            }
        }


        $Results

        } 
}

