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
  validate_string($sleeptime)

  #The inotify script
  file { '/usr/local/bin/csync2-inotify':
    ensure  => $ensure,
    mode    => '0654',
    owner   => '0',
    group   => '0',
    content => template('csync2/inotify_body.erb'),
  }

  #Basic upstart init script for inotify
  file { '/etc/systemd/system/csync2-inotify.service':
    ensure  => $ensure,
    source  => 'puppet:///modules/csync2/csync2-inotify.service',
    require => File['/usr/local/bin/csync2-inotify'],
    notify  => Exec['reload-systemd'],
  }

  #Selector for turning 'present' to true
  $service_ensure = $ensure ? {
    'present' => true,
    default   => false,
  }

  exec { 'reload-systemd':
    command      => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  #Start the csync2 service
  service { 'csync2-inotify':
    ensure  => $service_ensure,
    enable  => $service_ensure,
    require => File['/etc/systemd/system/csync2-inotify.service'],
  }


}
