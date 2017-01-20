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

  # /etc/systemd/logind.conf
  file { '/etc/systemd/logind.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/logind.erb"),
  }

  $hash_services = hiera_hash('systemd::service',undef)
  if $hash_services {
    create_resources(systemd::service,$hash_services)
  }
}
