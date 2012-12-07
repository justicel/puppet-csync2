#Defines a csync2 group single node. Implemented as a resource collection
#Options:
#[hostname] This specifies the hostname to use for the defined node. By default the fqdn/hostname of 
#the system.
#[ipaddress] The IP address to use to actually connect to the server. This could ALSO be a separate
#hostname. By default it's the primary IP on the system/server.
#[order] The default order to use. Defaults to 11, but this will need to be changed for additional groups.
#[configfile] You probably shouldn't touch this.

define csync2::groupnode (
  $group    = 'default',
  $order    = '11',
  $hostname = $::hostname, 
  $ipaddress = $::ipaddress,
  $configfile        = $csync2::params::configfile,
) {

  #The concat library is used here
  #Node is realized as the hostname and IP address for now
  #Will add an if statement eventually so you can specify only via hostname, etc.
  concat::fragment { "${group}_csync2_member_${name}":
    order	=> $order,
    target	=> $configfile,
    content	=> "	host ${hostname}@${ipaddress};\n",
  }
}
