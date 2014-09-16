#The base csync2 resource initialization. We can define some basic things such
#as if we should enable the firewall and what tools to use if so.
#Options:
#[firewall] This uses example42's firewall module by default. Others could be
#written. Probably want to use 'enable' here.
#[firewall_tool] The firewall type to utilize. By default is iptables
#[firewall_src] The source address for incoming connections. Likely will be
#your local net
#[firewall_dst] The incoming IP on the server/node to allow connections to.

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
  }
  concat::fragment{ 'csync2-header':
    target  => $::csync2::params::configfile,
    order   => '01',
    content => "#This file managed by Puppet\nnossl * *;\n",
  }

}
