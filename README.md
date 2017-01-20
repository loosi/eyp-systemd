# systemd

![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What systemd affects](#what-systemd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with systemd](#beginning-with-systemd)
4. [Usage](#usage)
4. [Hiera](#hiera)
6. [Reference](#reference)
7. [Limitations](#limitations)
8. [Development](#development)
    * [Contributing](#contributing)

## Overview

systemd service support

## Module Description

basic systemd support implemented:
* service definitions
* logind.conf (disables IPC deletion on user logout)

## Setup

### What systemd affects

- Creates service definitions: **/etc/systemd/system/${servicename}.service**
- Manages **/etc/systemd/logind.conf**

### Setup Requirements

This module requires pluginsync enabled

### Beginning with systemd

basic example from eyp-kibana:

```puppet
systemd::service { 'kibana':
  execstart => "${basedir}/${productname}/bin/kibana",
  require   => [ Class['systemd'], File["${basedir}/${productname}/config/kibana.yml"] ],
  before => Service['kibana'],
}
```

## Usage

add service dependency:

```puppet
systemd::service { 'oracleasm':
  description       => 'Load oracleasm Modules',
  after             => 'iscsi.service',
  type              => 'oneshot',
  remain_after_exit => true,
  execstart         => '/usr/sbin/service oracleasm start_sysctl',
  execstop          => '/usr/sbin/service oracleasm stop_sysctl',
  execreload        => '/usr/sbin/service oracleasm restart_sysctl',
}
```

env_vars usage example:

```puppet
systemd::service { 'tomcat7':
  user        => 'tomcat',
  group       => 'tomcat',
  execstart   => '/apps/tomcat/bin/startup.sh',
  execstop    => '/apps/tomcat/bin/startup.sh',
  forking     => true,
  description => 'Apache Tomcat Web Application Container',
  after       => 'network.target',
  restart     => 'no',
  env_vars    => ['"JAVA_OPTS=-Xms2048m -Xmx2048m -XX:MaxMetaspaceSize=512m"',
                  '"CATALINA_PID=/apps/tomcat/logs/catalina.pid"'],
}
```

system-v compatibility mode:

Use case: **eyp-mcaffee** uses the following to enable the ma service on CentOS 7

```puppet
include systemd

systemd::sysvwrapper { 'ma':
  initscript => '/etc/init.d/ma',
  notify     => Service['ma'],
  before     => Service['ma'],
}
```

This creates the following on the system:

systed service definition:

```
# cat /etc/systemd/system/ma.service
[Unit]

[Service]
ExecStart=/bin/bash /etc/init.d/ma.sysvwrapper.wrapper start
ExecStop=/bin/bash /etc/init.d/ma.sysvwrapper.wrapper stop
Restart=no
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ma
User=root
Group=root
Type=forking
PIDFile=/var/run/ma.sysvwrapper.pid

[Install]
WantedBy=multi-user.target
```

control script:
```
# cat /etc/init.d/ma.sysvwrapper.wrapper
#!/bin/bash

#
# puppet managed file
#

PIDFILE=/var/run/ma.sysvwrapper.pid

case $1 in
  start)
    /etc/init.d/ma $@
    sleep 1s;
    /etc/init.d/ma.sysvwrapper.status &
    echo $! > $PIDFILE

    /etc/init.d/ma status
    exit $?
  ;;
  *)
    /etc/init.d/ma $@
    exit $?
  ;;
esac
```

process checking ma status (to be able to report status to systemd):

```
ps auxf
(...)
root     27399  0.0  0.0 113120  1396 ?        S    Jan09   0:00 /bin/bash /etc/init.d/ma.sysvwrapper.status
root      7173  0.0  0.0 107896   608 ?        S    10:34   0:00  \_ sleep 10m
```

### Hiera
You may deploy the services via hiera definitions. For that you need to include the main class and define something like the following :
You can use all [Variables](#systemdservice) for a service.
```yaml
systemd::service:
  foooobar:
    user             : fooo
    group            : bar
    execstart        : /bin/true
    description      : This is a Foooooooobar Service
    execreload       : '/bin/echo'
    enable_service   : true
    requires         :
      - sshd.service
      - dbus.service


```

## Reference

### classes

#### systemd

* **removeipc**: IPC deletion on user logout (default: no)

### defines

#### systemd::service

* **execstart**: command to start daemon
* **execstop**: command to stop daemon (default: undef)
* **execreload**: commands or scripts to be executed when the unit is reloaded (default: undef)
* **restart**: restart daemon if crashes (default: always)
* **user**: username to use (default: root)
* **group**: group to use (default: root)
* **servicename**: service name (default: resource's name)
* **forking**: expect fork to background (default: false)
* **pid_file**: PIDFile specifies a stable PID for the main process of the service (default: undef)
* **description**: A meaningful description of the unit. This text is displayed for example in the output of the systemctl status command (default: undef)
* **after**: Defines the order in which units are started (default: undef)
* **remain_after_exit**: If set to True, the service is considered active even when all its processes exited. (default: undef)
* **type**: Configures the unit process startup type that affects the functionality of ExecStart and related options (default: undef)
* **env_vars**: array of environment variables (default: undef)
* **wants**: A weaker version of Requires=. Units listed in this option will be started if the configuring unit is. However, if the listed units fail to start or cannot be added to the transaction, this has no impact on the validity of the transaction as a whole (default: [])
* **before_units**: Configures ordering dependencies between units, for example, if a unit foo.service contains a setting Before=bar.service and both units are being started, bar.service's start-up is delayed until foo.service is started up (default: [])
* **after_units**: Configures ordering dependencies between units. (default: [])
* **requires**: Configures requirement dependencies on other units. If this unit gets activated, the units listed here will be activated as well. If one of the other units gets deactivated or its activation fails, this unit will be deactivated (default: [])
* **conflicts**: A space-separated list of unit names. Configures negative requirement dependencies. If a unit has a Conflicts= setting on another unit, starting the former will stop the latter and vice versa (default: [])
* **wantedby**: Array, this has the effect that a dependency of type **Wants=** is added from the listed unit to the current unit (default: ['multi-user.target'])
* **requiredby**: Array, this has the effect that a dependency of type **Requires=** is added from the listed unit to the current unit (default: [])
* **working_directory**: Sets the parameter "WorkingDirectory" for systemd unit. Sets the working dir for the command you want to execute (default: undef)
* **execstart_pre**: Sets the parameter "ExecStartPre" for systemd unit. Runs a script before the **ExecStart** is executed. (default: undef)
* **enable_service**: Enables the service via puppet (means autostart). (default: false)
* **ensure_service**: Ensures service is running or not via puppet). (default: true)
* **requiredby**: Array, this has the effect that a dependency of type **Requires=** is added from the listed unit to the current unit (default: [])

#### systemd::sysvwrapper

system-v compatibility

* **initscript**: requred (system-v init script to use)
* **servicename**: service name (default: resource's name)
* **check_time**: check interval -time between **initscript** status checks- (default: 10m)

## Limitations

Should work anywhere, tested on CentOS 7

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
