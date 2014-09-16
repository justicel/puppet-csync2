#Defines a csync2 group single node. Implemented as a resource collection
#Options:
#[hostname] This specifies the hostname to use for the defined node. By default
#the fqdn/hostname of
#the system.
#[ipaddress] The IP address to use to actually connect to the server. This
#could ALSO be a separate hostname. By default it's the primary IP on the
#system/server.
#[configfile] You probably shouldn't touch this.

define csync2::groupnode (
  $group      = 'default',
  $hostname   = $::hostname,
  $ipaddress  = $::ipaddress,
  $configfile = $::csync2::params::configfile,
  $slave      = false,
) {
  include ::csync2::params

  #Set this node as a slave if defined
  $hostname_true = $slave ? {
    true    => "(${hostname})",
    default => $hostname,
  }

  #The concat library is used here
  #Node is realized as the hostname and IP address for now
  #Will add an 'if' eventually so you can specify only via hostname, etc.
  concat::fragment { "${group}_csync2_member_${name}":
    order   => "20-${group}-${name}",
    target  => $configfile,
    content => "  host ${hostname_true}@${ipaddress};\n",
  }
}
