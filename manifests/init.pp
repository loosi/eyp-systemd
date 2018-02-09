#
# https://wiki.archlinux.org/index.php/systemd#Service_types
#
class systemd($removeipc='no') inherits systemd::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

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
}
