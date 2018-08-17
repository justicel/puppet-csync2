#If additional OS versions are to be added eventually for support the config
#path and file will have to be changed to something else.
#
class csync2::params {

  #Some class defaults
  $checkfreq        = '5'
  $default_includes = ['/var/tmp']
  $default_excludes = undef
  $default_auto     = 'none'
  $default_action   = undef
  $default_key      = 'puppet:///modules/csync2/keys/default.key'

  case $::osfamily {
    'RedHat': {
      if $facts['operatingsystemrelease'] > "6" {
        $csync2_source_url    = 'http://oss.linbit.com/csync2/csync2-2.0.tar.gz'
        $csync2_rhel_version  = '2.0'
        $configfile           = '/usr/local/etc/csync2.cfg'
      }else {
        $configfile      = '/etc/csync2/csync2.cfg'

      }

      $csync2_exec     = '/usr/sbin/csync2'
      $csync2_package  = 'csync2'
      $inotify_package = 'inotify-tools'
      $configpath      = '/etc/csync2'

    }
    'Debian': {
      $configpath      = '/etc'
      $configfile      = '/etc/csync2.cfg'
      $csync2_exec     = '/usr/sbin/csync2'
      $csync2_package  = 'csync2'
      $inotify_package = 'inotify-tools'
    }
    default: {
      fail("Class['csync2::params']: Unsupported OS: ${::osfamily}")
    }
  }

}
