只能安装vagrant_2.0.1_x86_64.msi版本，最新版本有问题。

## 先安装NAT:
用powershell管理员权限安装：
```bash
New-VMSwitch –SwitchName "NATSwitch" –SwitchType Internal
New-NetIPAddress –IPAddress 192.168.11.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat –Name MyNATnetwork –InternalIPInterfaceAddressPrefix 192.168.11.0/24
```

