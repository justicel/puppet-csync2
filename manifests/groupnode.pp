define csync2::groupnode (
  $group    = 'default',
  $order    = '11',
  $hostname = $::fqdn, 
  $ipaddress = $::ipaddress,
  $configfile        = $csync2::params::configfile,
) {
  concat::fragment { "${group}_csync2_member_${name}":
    order	=> $order,
    target	=> $configfile,
    content	=> "	host ${hostname}@${ipaddress};\n",
  }
}
