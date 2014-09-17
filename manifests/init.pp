#The base csync2 resource initialization.
#Options:
#[ensure] Set to (absent/present). Defaults to present for the csync2 resources
#
#[checkfreq] The default check frequency for all groups on the csync2 hosts
#
class csync2 (
  $ensure        = 'present',
  $checkfreq     = $::csync2::params::checkfreq,
)
inherits csync2::params
{

  #Install the basic packages
  ensure_packages( [$::csync2::params::csync2_package, $::csync2::params::inotify_package],
    { ensure => $ensure }
  )

  #Csync2 needs xinetd
  xinetd::service { 'csync2':
    ensure       => $ensure,
    port         => '30865',
    server       => $::csync2::params::csync2_exec,
    server_args  => '-i',
    flags        => 'REUSE',
    protocol     => 'tcp',
    require      => Concat[$::csync2::params::configfile],
  }

  #Build a very basic concat csync2 file
  concat { $::csync2::params::configfile:
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package[$::csync2::params::csync2_package],
    notify  => Exec['csync2_checksync'],
  }
  concat::fragment{ 'csync2-header':
    target  => $::csync2::params::configfile,
    order   => '01',
    content => "#This file managed by Puppet\nnossl * *;\n",
  }

}
