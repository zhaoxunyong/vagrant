https://quotidian-ennui.github.io/blog/2016/08/17/vagrant-windows10-hyperv/
https://www.thirdtier.net/hyper-v-set-up-an-internal-network-for-hostguest-file-and-service-sharing/

New-VMSwitch –SwitchName "NATSwitch" –SwitchType Internal
New-NetIPAddress –IPAddress 192.168.11.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat –Name MyNATnetwork –InternalIPInterfaceAddressPrefix 192.168.11.0/24
New-NetNat –Name MyNATnetwork –InternalIPInterfaceAddressPrefix 172.21.21.0/24

Get-VMSwitch
Remove-VMSwitch -Name NATSwitch

Get-NetNat
Remove-NetNat -Name MyNATnetwork