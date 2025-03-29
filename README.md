# Specific hardware monitoring templates for Zabbix
[![License](https://img.shields.io/badge/License-MIT--Clause-blue.svg)](https://github.com/yvoinov/zabbix-templates-hardware-monitoring/blob/main/LICENSE)
## Motivation

These templates were developed due to the fact that some specific monitoring tasks, which are publicly available, are either solved unsatisfactorily or incompletely. In particular, monitoring SMART disks connected to the SmartArray controller via smartmontools extremely overloads the controller and leads to a dramatic increase in IO Wait. To zap this problem, a complete solution for general monitoring of the array disks by means of the vendor (the controller itself) was developed. The state of the controller itself and its components is also monitored.

In addition, monitoring the hardware of Windows workstations is also not well covered. For this reason, a generalized template for monitoring a typical workstation by means of WMI in combination with [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) was developed.

Note: Although the templates were developed for Zabbix 7.0, they will work on earlier versions as well. Just adjust the version in the template.

## Using template HP RAID

Just put HP_RAID.conf to zabbix_agent.d (zabbix_agent2.d) or add file contents to zabbix_agent.conf (for older agents) and restart agent.

Then import template into Zabbix and apply to host(s).

## Using template Windows hardware by Zabbix agent

On client must be installed LibreHardwareMonitor and added to run on windows startup.

Then import template into Zabbix and apply to host(s).


