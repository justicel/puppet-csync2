Puppet Csync2 
=============

Puppet module for managing csync2.
For general csync2 information and documentation, please refer to: http://oss.linbit.com/csync2/

This module utilizes a resource collector on each defined node to build a sync configuration.

## Example usage

First you will need to define a csync2 GROUP key using csync2 on the command line:

```bash
csync2 -k csync2.example.key
```

Deploy that key with puppet and configure the csync2 class:

```puppet
class {'csync2': }

csync2::groupnode { $::fqdn:
  group      => 'default', }

csync2::group { 'default':
  includes   => ['/tmp/example/path1', '/tmp/example/path2'],
  excludes   => ['*.svn'],
  auto       => 'younger',
  group_key  => 'example',
  key_source => 'puppet:///modules/csync2/keys/csync2.example.key',
}
```

## Requirements

- [puppetlabs-concat](https://github.com/puppetlabs/puppetlabs-concat)

