define systemd::service (
                          $execstart,
                          $execstop          = undef,
                          $execreload        = undef,
                          $restart           = 'always',
                          $user              = 'root',
                          $group             = 'root',
                          $servicename       = $name,
                          $forking           = false,
                          $pid_file          = undef,
                          $description       = undef,
                          $after             = undef,
                          $remain_after_exit = undef,
                          $type              = undef,
                          $env_vars          = undef,
                          $wants             = [],
                          $wantedby          = [ 'multi-user.target' ],
                          $requiredby        = [],
                          $after_units       = [],
                          $before_units      = [],
                          $requires          = [],
                          $conflicts         = [],
                          $working_directory = undef,
                          $execstart_pre     = undef,
                        ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if ($env_vars != undef )
  {
    validate_array($env_vars)
  }

  if($type!=undef and $forking==true)
  {
    fail('Incompatible options: type / forking')
  }

  validate_re($restart, [ '^always$', '^no$'], "Not a supported restart type: ${restart}")

  validate_array($wants)
  validate_array($wantedby)
  validate_array($requiredby)
  validate_array($after_units)
  validate_array($before_units)
  validate_array($requires)
  validate_array($conflicts)

  include ::systemd

  file { "/etc/systemd/system/${servicename}.service":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/service.erb"),
    notify  => Exec['systemctl reload'],
  }

}
