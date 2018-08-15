#The base csync2 resource initialization.
#Options:
#[ensure] Set to (absent/present). Defaults to present for the csync2 resources
#
#[checkfreq] The default check frequency for all groups on the csync2 hosts
#
class csync2 (
  $ensure              = 'present',
  $enable_inotify      = true,
  $checkfreq           = $::csync2::params::checkfreq,
  $csync2_package      = $::csync2::params::csync2_package,
  $inotify_package     = $::csync2::params::inotify_package,
  $csync2_exec         = $::csync2::params::csync2_exec,
  $csync2_config       = $::csync2::params::configfile,
  $csync2_rhel_version = $::csync2::params::csync2_rhel_version,
  $csync2_source_url   = $::csync2::params::csync2_source_url,
) inherits ::csync2::params {

  #Validate variables
  validate_re($ensure, '^present$|^absent$')
  validate_string($csync2_package)
  validate_string($inotify_package)
  validate_absolute_path($csync2_exec)
  validate_absolute_path($csync2_config)

  #Install the basic packages
  if $facts['osfamily'] == "RedHat" and $facts['operatingsystemrelease'] > "6" {
    ["$inotify_package", "gcc", "librsync", "librsync-devel", "sqlite-devel", "gnutls-devel"].each | $index, $name | {
      package { $name:
        ensure => $ensure,
        before => Archive["/usr/local/src/csync2-$csync2_rhel_version.tar.gz"],
      }
    }
    archive { "/usr/local/src/csync2-$csync2_rhel_version.tar.gz":
      ensure        => present,
      extract       => true,
      extract_path  => '/usr/local/src',
      source        => "$csync2_source_url",
      creates       => "/usr/local/src/csync2-$csync2_rhel_version",
      cleanup       => false,
    }->
    exec { "Build and install csync2 on RHEL":
      command => "cd /usr/local/src/csync2-$csync2_rhel_version && ./configure && make && make install && mkdir $configpath && ln -s /usr/local/sbin/csync2 /usr/sbin/ && ln -s /usr/local/etc/csync2.cfg $configpath",
      unless  => "test -e /usr/sbin/csync2",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    }
  } else {
    ensure_packages( [$csync2_package, $inotify_package],
      { ensure => $ensure }
    )
  }
  
  #Csync2 needs xinetd
  xinetd::service { 'csync2':
    ensure        => $ensure,
    user          => 'root',
    group         => 'root',
    port          => '30865',
    server        => $csync2_exec,
    server_args   => '-i',
    flags         => 'REUSE',
    protocol      => 'tcp',
    service_type  => 'UNLISTED',
  }

}
