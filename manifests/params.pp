class csync2::params {
  $port = 30865
  $protocol = 'tcp'

  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress

  $configpath   = '/etc/csync2'
  $configfile   = '/etc/csync2/csync2.cfg'
}
