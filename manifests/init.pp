#The base csync2 resource initialization. We can define some basic things such as if we should enable 
#the firewall and what tools to use if so.
#Options:
#[firewall] This uses example42's firewall module by default. Others could be written. Probably want to
#use 'enable' here.
#[firewall_tool] The firewall type to utilize. By default is iptables
#[firewall_src] The source address for incoming connections. Likely will be your local net
#[firewall_dst] The incoming IP on the server/node to allow connections to.

class csync2 (
  $firewall      = $csync2::params::firewall,
  $firewall_tool = $csync2::params::firewall_tool,
  $firewall_src  = $csync2::params::firewall_src,
  $firewall_dst  = $csync2::params::firewall_dst,
)
inherits csync2::params 
{ 
 
  #Need concat to make this work
  include concat::setup

  #Install the basic packages		
  package { ["csync2", "inotify-tools"]:
    ensure	=> present,
  }

  #Csync2 needs xinetd
  service { 'xinetd':
    ensure	=> running,
    enable	=> true,
    require	=> Concat["$configfile"],
  }

  #Copy over the csync xinetd file to the node (enabling it)
  file { '/etc/xinetd.d/csync2':
    source => 'puppet:///modules/csync2/csync2.xinetd',
    notify => Service['xinetd'],
  }

  #Build a very basic concat csync2 file
  concat { "$configfile":
    owner	=> '0',
    group	=> '0',
    mode	=> '0644',
    require	=> Package['csync2'],
    notify	=> Service['xinetd'],
  }
  concat::fragment{ 'csync2-header':
    target	=> "${configfile}",
    order	=> '01',
    content	=> "#This file managed by Puppet\nnossl * *;\n",
  }

  #Setup basic firewall
  firewall { "csync2_${csync2::protocol}_${csync2::port}":
    source      => $csync2::firewall_src,
    destination => $csync2::firewall_dst,
    protocol    => $csync2::protocol,
    port        => $csync2::port,
    action      => 'allow',
    direction   => 'input',
    tool        => $csync2::firewall_tool,
    enable      => $csync2::manage_firewall,
  }


}
