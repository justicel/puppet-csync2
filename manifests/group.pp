#Resource definition for a csync2 GROUP. This is the core resource realized on each node in the csync2 
#cluster. 
#Options:
#[group_key] This defines the name of the group-key to utilize for the defined group. By default it
#will be based off of the NAME of the defined resource.
#[includes] The list of folders, or single folders to use with a sync group. Defaults to a test path.
#[excludes] A default list of files or folders to EXCLUDE from syncing. This defaults to everything so
#make sure to modify this option!
#[order] The default order of the resource group. Defaults to 10, but if you realize multiple groups
#you will need to redefine this.
#[configfile] The default config-file to use for csync2. You probably shouldn't modify.
#[configpath] The default config-path to use for csync2.
#[auto] The logic to use for syncing of conflicts. This defaults to none. You can choose from:
#none, first, younger, older, bigger, smaller, left, right. Probably younger or none is what you want.
#[cron] Should we run the sync group task automatically? By default, no. Use false, or true to enable.
#[cronfreq] The amount of sleep timing to wait after a file modification has been detected. Default to 5s.

#Base resource definition for a csync2 group.
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
  file { "${configpath}/${group_key}":
    source  => "puppet:///modules/csync2/keys/${group_key}",
    ensure  => present,
    replace => true,
    group   => '0',
    owner   => '0',
    mode    => '0600',
  }

  #Define the csync2 group
  concat::fragment { "${name}_csync2_header":
    order	=> $order,
    target	=> $configfile,
    content	=> "group ${name}\n{\n\n",
  }

  ##Set the cron in minutes or ignore if not set
  if $cron == 'true' {
#    cron { 'csync2':
#      command => "/usr/sbin/csync2 -x",
#      user    => 'root',
#      minute  => "*/$cronfreq",
#    }
    #Replaced cron-job with inotify script
    class { 'csync2::inotify':
      syncfolders => $includes,
      sleeptimer => $cronfreq,
    }
  }

  #Bring in the cluster members
  Csync2::Groupnode <<| group == $name |>>

  #The main csync2 config body as defined by template and concat.
  concat::fragment { "${name}_csync2_body":
    order	=> $order + 2,
    target	=> $configfile,
    content	=> template('csync2/csync2_body.erb'),
  }

}
