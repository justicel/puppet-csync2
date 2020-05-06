#Internal inotify class description.
#
#This defines a simple script which launches into the background on the node
#waiting for inotify data.

class csync2::inotify (
  $ensure      = $::csync2::ensure,
  $syncfolders = [],
  $sleeptimer  = $::csync2::checkfreq,
) {
  include ::csync2

  #Validate variables
  validate_re($ensure, '^present$|^absent$')
  validate_array($syncfolders)
  validate_string($sleeptimer)

  #The inotify script
  file { '/usr/local/bin/csync2-inotify':
    ensure  => $ensure,
    mode    => '0654',
    owner   => '0',
    group   => '0',
    content => template('csync2/inotify_body.erb'),
  }

  case $service_provider {

  'upstart': {
      #Basic upstart init script for inotify
      file { 'csync2-service':
        ensure  => $ensure,
        source  => 'puppet:///modules/csync2/csync2.conf',
        path    => '/etc/init/csync2-inotify.conf',
        require => File['/usr/local/bin/csync2-inotify'],
      }
    }

  'systemd': {
      #Basic upstart init script for inotify
      file { 'csync2-service':
        ensure  => $ensure,
        path    => '/etc/systemd/system/csync2-inotify.service',
        source  => 'puppet:///modules/csync2/csync2-inotify.service',
        require => File['/usr/local/bin/csync2-inotify'],
        notify  => Exec['reload-systemd'],
      }
      exec { 'reload-systemd':
        command      => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
      }
    }
  }

  #Selector for turning 'present' to true
  $service_ensure = $ensure ? {
    'present' => true,
    default   => false,
  }

  #Start the csync2 service
  service { 'csync2-inotify':
    ensure  => $service_ensure,
    enable  => $service_ensure,
    require => File['csync2-service'],
  }

}
