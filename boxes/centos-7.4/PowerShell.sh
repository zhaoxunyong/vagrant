New-VMSwitch –SwitchName "NATSwitch" –SwitchType Internal
New-NetIPAddress –IPAddress 192.168.11.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat –Name MyNATnetwork –InternalIPInterfaceAddressPrefix 192.168.11.0/24

Get-VMSwitch

get-netnat
Remove-NetNat -Name MyNATnetwork