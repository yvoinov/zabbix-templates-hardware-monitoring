# Specific hardware monitoring templates for Zabbix
[![License](https://img.shields.io/badge/License-MIT--Clause-blue.svg)](https://github.com/yvoinov/zabbix-templates-hardware-monitoring/blob/main/LICENSE)
## Motivation

These templates were developed due to the fact that some specific monitoring tasks, which are publicly available, are either solved unsatisfactorily or incompletely. In particular, monitoring SMART disks connected to the SmartArray controller via smartmontools extremely overloads the controller and leads to a dramatic increase in IO Wait. To zap this problem, a complete solution for general monitoring of the array disks by means of the vendor (the controller itself) was developed. The state of the controller itself and its components is also monitored.

Also, a SMART monitoring template for dual system boot disks (usually mirrored, especially with ZFS) has been added.

In addition, monitoring the hardware of Windows workstations is also not well covered. For this reason, a generalized template for monitoring a typical workstation by means of WMI in combination with [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) was developed.

Note: Although the templates were developed for Zabbix 7.0, they will work on earlier versions as well. Just adjust the version in the template.

## Using template HP RAID

Just put HP_RAID.conf to zabbix_agent.d (zabbix_agent2.d) or add file contents to zabbix_agent.conf (for older agents) and restart agent.

Then import template into Zabbix and apply to host(s).

### Solaris

Solaris requires some special handling to work this things.

Use this oneliners with user params (Make sure you are using the correct utility versions and environment, which may vary between Solaris versions; this example for Solaris 10 with OpenCSW coreutils):
```
UserParameter=hp.raid.ctrl.status,pfexec /opt/HPQacucli/sbin/hpacucli ctrl slot=0 show status | /opt/csw/gnu/grep 'Controller' | /opt/csw/gnu/grep -v -e '^$' -e 'Slot' -e 'OK$' | /opt/csw/gnu/wc -l
UserParameter=hp.raid.ctrl.cache,pfexec /opt/HPQacucli/sbin/hpacucli ctrl slot=0 show status | /opt/csw/gnu/grep 'Cache' | /opt/csw/gnu/grep -v -e '^$' -e 'Slot' -e 'OK$' | /opt/csw/gnu/wc -l
UserParameter=hp.raid.ctrl.battery,pfexec /opt/HPQacucli/sbin/hpacucli ctrl slot=0 show status | /opt/csw/gnu/grep 'Battery' | /opt/csw/gnu/grep -v -e '^$' -e 'Slot' -e 'OK$' | /opt/csw/gnu/wc -l
UserParameter=hp.raid.status,pfexec /opt/HPQacucli/sbin/hpacucli ctrl slot=0 pd all show status | /opt/csw/gnu/grep -v -e '^$' -e 'OK$' | /opt/csw/gnu/wc -l
```
Then run:
```sh
usermod -s /bin/sh zabbix
passwd -N zabbix
echo "Zabbix HP CLI:::Allows running HP CLI with UID=0" >> /etc/security/prof_attr
echo "Zabbix HP CLI:solaris:cmd:::/opt/HPQacucli/sbin/hpacucli:uid=0" >> /etc/security/exec_attr
echo "zabbix::::type=normal;profiles=Zabbix HP CLI;roles=" >> /etc/user_attr
```
and restart agent.

## Using template Solaris SMART

Use this oneliners with user params (Make sure you are using the correct utility versions and environment, which may vary between Solaris versions; this example for Solaris 10 with OpenCSW coreutils) or put Solaris_SMART.conf to zabbix_agent.d (zabbix_agent2.d):
```
# Get S.M.A.R.T status from system disks
# Modify disks according to your system and configuration (see smartctl --scan).
#
# Add to agent config on SPARC:
UserParameter=sun.disk1.smart.status,pfexec /opt/csw/sbin/smartctl -H /dev/rdsk/c4t20000014C371A0E1d0s0 -d scsi | /opt/csw/gnu/grep 'Health' | /opt/csw/gnu/grep -v -e '^$' -e 'OK$' | /opt/csw/gnu/wc -l
UserParameter=sun.disk2.smart.status,pfexec /opt/csw/sbin/smartctl -H /dev/rdsk/c4t20000014C37192B0d0s0 -d scsi | /opt/csw/gnu/grep 'Health' | /opt/csw/gnu/grep -v -e '^$' -e 'OK$' | /opt/csw/gnu/wc -l

# or on x86:
# UserParameter=sun.disk1.smart.status,pfexec /opt/csw/sbin/smartctl -H /dev/rdsk/c2t0d0s0 -d scsi | /opt/csw/gnu/grep 'Health' | /opt/csw/gnu/grep -v -e '^$' -e 'OK$' | /opt/csw/gnu/wc -l
# UserParameter=sun.disk2.smart.status,pfexec /opt/csw/sbin/smartctl -H /dev/rdsk/c2t1d0s0 -d scsi | /opt/csw/gnu/grep 'Health' | /opt/csw/gnu/grep -v -e '^$' -e 'OK$' | /opt/csw/gnu/wc -l
```
Then run:
```sh
usermod -s /bin/sh zabbix
passwd -N zabbix
echo "Zabbix smartctl CLI:::Allows running smartctl CLI with UID=0" >> /etc/security/prof_attr
echo "Zabbix smartctl CLI:solaris:cmd:::/opt/csw/sbin/smartctl:uid=0" >> /etc/security/exec_attr
echo "zabbix::::type=normal;profiles=Zabbix smartctl CLI;roles=" >> /etc/user_attr
```
and restart agent.

## Using template Windows hardware by Zabbix agent

On client must be installed LibreHardwareMonitor and added to run on windows startup.

Then import template into Zabbix and apply to host(s).
