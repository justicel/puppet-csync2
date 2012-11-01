This is the first release of a csync2 module for Puppet.
It is likely buggy, crappy and will eat you puppet server.

Here is what it can do, followed by an example configuration.
You can use csync2 much like other tools (Unison, rsync, etc.), but what is nice about Csync2 is it is
very fast and maintains a sqlite database of all file changes.
This means it is capable of managing several hundred thousand files to be synced between multiple systems
with very little lag between results (essentially a few seconds most of the time). Unlike rsync you can do multi-write style replication which is a requirement if you have several web-servers all being written to.

This module utilizes a resource collector on each defined node to build a sync configuration.

Example usage below, all configs go into your node configuration:

class {'csync2': }

If you have the example42 firewall module installed you can open ports automatically:
`class {'csync2':
  firewall        => true,
  firewall_tool   => 'iptables', }

@@csync2::groupnode { $fqdn:
    group       => '<appname>', }

csync2::group { '<appname>':
  includes => ["path1", "path2"],
  excludes => '*.svn',
  auto     => 'younger',
  cron     => 'true', }
`
If you use cron in your configuration this will enable the ability to have inotify based syncing. 
If you don't enable cron then you will have to manually add a cron entry or similar.

For more general csync2 documentation, please refer to: http://oss.linbit.com/csync2/
