#
# https://wiki.archlinux.org/index.php/systemd#Service_types
#
class systemd($removeipc='no') inherits systemd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { 'systemctl daemon-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  #TODO: compatibility, to be removed in 0.2
  # related: https://github.com/NTTCom-MS/eyp-systemd/issues/35
  exec { 'systemctl reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  augeas{ 'set_logind_conf' :
    lens    => "Puppet.lns",
    incl    => "/etc/systemd/logind.conf",
    changes => [
        "set Login/RemoveIPC ${removeipc}",
    ],
  }

  $hash_services = hiera_hash('systemd::service',undef)
  if $hash_services {
    create_resources(systemd::service,$hash_services)
  }
  #file { '/etc/systemd/logind.conf':
  #  ensure  => 'present',
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0644',
  #  content => template("${module_name}/logind.erb"),
  #}
}
