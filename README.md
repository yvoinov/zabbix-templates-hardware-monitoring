# Specific hardware monitoring templates for Zabbix
[![License](https://img.shields.io/badge/License-MIT--Clause-blue.svg)](https://github.com/yvoinov/zabbix-templates-hardware-monitoring/blob/main/LICENSE)
## Motivation

These templates were developed due to the fact that some specific monitoring tasks, which are publicly available, are either solved unsatisfactorily or incompletely. In particular, monitoring SMART disks connected to the SmartArray controller via smartmontools extremely overloads the controller and leads to a dramatic increase in IO Wait. To zap this problem, a complete solution for general monitoring of the array disks by means of the vendor (the controller itself) was developed.

In addition, monitoring the hardware of Windows workstations is also not well covered. For this reason, a generalized template for monitoring a typical workstation by means of WMI in combination with [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) was developed.

## Using template HP RAID

For template require to add UserParameter in agent config:
```sh
UserParameter=hp.raid.status,sudo /usr/sbin/hpacucli ctrl slot=0 pd all show status | grep -v -e '^$' -e 'OK$' | wc -l
```
(for emberred controller)

or
```sh
UserParameter=hp.raid.status,sudo /usr/sbin/hpacucli ctrl slot=1 pd all show status | grep -v -e '^$' -e 'OK$' | wc -l
```
(for PCIe controller)

and restart agent.

Then import template into Zabbix and apply to host(s).

## Using template Windows hardware by Zabbix agent

On client must be installed LibreHardwareMonitor and added to run on windows startup.

Then import template into Zabbix and apply to host(s).

Note: Although the templates were developed for Zabbix 7.0, they will work on earlier versions as well. Just adjust the version in the template.


