class csync2::inotify (
$syncfolders = undef,
$sleeptimer = '5',
) {

  #The inotify script
  file { '/usr/local/bin/csync2-inotify':
    ensure  => present,
    mode    => 0654,
    owner   => root,
    group   => 0,
    content => template("csync2/inotify_body.erb")
  }

  #The inotify cron
  file { '/etc/rc.d/init.d/csync2-inotify':
    ensure  => present,
    mode    => 0654,
    owner   => root,
    group   => 0,
    source  => 'puppet:///modules/csync2/csync2-inotify',
    notify  => Service['csync2-inotify'],
  }

  service { 'csync2-inotify':
    enable => true,
    ensure => running,
    require => File['/etc/rc.d/init.d/csync2-inotify'],
  }

}
