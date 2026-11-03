# Specific hardware monitoring templates for Zabbix
[![License](https://img.shields.io/badge/License-MIT--Clause-blue.svg)](https://github.com/yvoinov/zabbix-templates-hardware-monitoring/blob/main/LICENSE)
## Motivation

These templates were developed due to the fact that some specific monitoring tasks, which are publicly available, are either solved unsatisfactorily or incompletely. In particular, monitoring SMART disks connected to the SmartArray controller via smartmontools extremely overloads the controller and leads to a dramatic increase in IO Wait. To zap this problem, a complete solution for general monitoring of the array disks by means of the vendor (the controller itself) was developed. The state of the controller itself and its components is also monitored.

Also, a SMART monitoring template for dual system boot disks (usually mirrored, especially with ZFS) has been added.

In addition, monitoring the hardware of Windows workstations is also not well covered. For this reason, a generalized templates for monitoring a typical workstation by means of WMI/JSON in combination with [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor)/[OpenHardwareMonitor](https://openhardwaremonitor.org/) was developed.

**Note:** Although the templates were developed for Zabbix 7.0, they will work on earlier versions as well. Just adjust the version in the template.

## Using template Adaptec RAID

First download and install arcconf. For example, from [here](https://hwraid.le-vert.net/debian/pool-buster/arcconf-1.07)

Add /usr/sbin/arcconf to sudoers. For example, /etc/sudoers.d/zabbix file should comtains:
```sh
zabbix ALL=(ALL) NOPASSWD:/usr/sbin/arcconf
```
For template require to add UserParameter in agent config:
```sh
UserParameter=adaptec.ld.failed,sudo /usr/sbin/arcconf GETCONFIG 1 | grep "Logical devices" | awk -F "/" '{print $4}'
UserParameter=adaptec.ld.degraded,sudo /usr/sbin/arcconf GETCONFIG 1 | grep "Logical devices" | awk -F "/" '{print $5}'
UserParameter=adaptec.ctrl.status,sudo /usr/sbin/arcconf GETCONFIG 1 | grep "Controller Status" | grep -vc Optimal
```
Or put Adaptec_RAID.conf to zabbix_agent.d (zabbix_agent2.d) or add file contents to zabbix_agent.conf (for older agents) and restart agent.

Then import template into Zabbix and apply to host(s).

## Using template HP RAID

Just put HP_RAID.conf to zabbix_agent.d (zabbix_agent2.d) or add file contents to zabbix_agent.conf (for older agents) and restart agent.

Then import template into Zabbix and apply to host(s).

### Solaris

Solaris requires some special handling to work this things.

Use this oneliners with user params (Make sure you are using the correct utility versions and environment, which may vary between Solaris versions; this example for Solaris 10 with OpenCSW coreutils):
```sh
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

**Note:** When used together with other monitoring systems, it is possible to overlap the execution of the hpacucli utility, which leads to false positives of the hp.raid.status key and/or timeout errors with other keys. In this case, a wrapper script is used for the call:
```sh
UserParameter=hp.raid.status,/usr/local/bin/zabbix_safe_hpacucli.sh raid
```
Place  it  in  /usr/local/bin and grant execution rights. The script is dual-platform. Set the ctrl_slot variable in the script to the correct value corresponding to your controller.

The same can be done with the rest of the keys:
```sh
UserParameter=hp.raid.ctrl.status,/usr/local/bin/zabbix_safe_hpacucli.sh ctrl
UserParameter=hp.raid.ctrl.cache,/usr/local/bin/zabbix_safe_hpacucli.sh cache
UserParameter=hp.raid.ctrl.battery,/usr/local/bin/zabbix_safe_hpacucli.sh battery
```
Please note that the script only supports these command line arguments.

## Using template Solaris SMART

Use this oneliners with user params (Make sure you are using the correct utility versions and environment, which may vary between Solaris versions; this example for Solaris 10 with OpenCSW coreutils) or put Solaris_SMART.conf to zabbix_agent.d (zabbix_agent2.d):
```sh
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

**Note:** Disk names may vary depending on multipathing, disk connections on the server, etc.

## Using template Windows hardware by Zabbix agent

On client must be installed LibreHardwareMonitor/OpenHardwareMonitor and added to run on windows startup.

Then import template into Zabbix and apply to host(s).

**Note:** It is recommended to modify the autorun task in the Task Scheduler so that the monitor is launched not at the login of any user, but at the startup of the system; in addition, it is recommended to make it a hidden Windows task and run with the highest rights. Also modify the options of the monitor itself to start minimized.

Since WMI technology has been deprecated, LibreHardwareMonitor/OpenHardwareMonitor contain a web server that returns data in JSON. For this reason, an updated **Windows hardware template by Zabbix agent HTTP** has been written. To use it, you must enable the web listener in the application settings before launching it in the task scheduler.
