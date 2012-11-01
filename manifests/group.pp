define csync2::group (
  $group_key  = "csync2.${name}.key",
  $includes   = '/var/tmp',
  $excludes   = '.*',
  $order      = '10',
  $configfile = $csync2::params::configfile,
  $configpath = $csync2::params::configpath,
  $auto	      = 'none',
  $cron	      = 'false',
  $cronfreq   = '5',
) {

  #Copy the key to the host
  file { "${configpath}${group_key}":
    source => "puppet:///modules/csync2/${group_key}",
    ensure => present,
    group  => '0',
    owner  => '0',
    mode   => '0600',
  }

  #Define the csync2 group
  concat::fragment { "${name}_csync2_header":
    order	=> $order,
    target	=> $configfile,
    content	=> "group ${name}\n{\n\n",
  }

  #Set the cron in minutes or ignore if not set
  if $cron == 'true' {
#    cron { 'csync2':
#      command => "/usr/sbin/csync2 -x",
#      user    => 'root',
#      minute  => "*/$cronfreq",
#    }
    #Replaced cron-job with inotify script
    class { 'csync2::inotify':
      syncfolders => $includes,
      sleeptimer => '1',
    }
  }

  #Bring in the cluster members
  Csync2::Groupnode <<| group == $name |>>

  concat::fragment { "${name}_csync2_body":
    order	=> $order + 2,
    target	=> $configfile,
    content	=> template('csync2/csync2_body.erb'),
  }

}
