class systemd::params {

  case $::osfamily
  {
    'redhat' :
    {
      case $::operatingsystemrelease
      {
        /^7.*$/:
        {
        }
        default: { fail('Unsupported RHEL/CentOS version!')  }
      }
    }
    'Suse' :
    {
      case $::operatingsystemrelease
      {
        /^13.2|42.*$/:
        {
        }
        default: { fail('Unsupported Suse/OpenSuse version!')  }
      }
    }
    'Debian':
    {
      case $::operatingsystem
      {
        'Ubuntu':
        {
          case $::operatingsystemrelease
          {
            /^16.*$/:
            {
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian':
        {
          case $::operatingsystemrelease
          {
            /^8.*$/:
            {
            }
            default: { fail("Unsupported Debian version! - ${::operatingsystemrelease}")  }
          }
        }
        default: { fail('Unsupported Debian flavour!')  }
      }
    }
    default  : { fail('Unsupported OS!') }
  }
}
