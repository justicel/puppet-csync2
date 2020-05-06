# Installs and manages Csync2 with iNotify support
#
# Options:
# [ensure] Set to (absent/present). Defaults to present for the csync2 resources
#
# [checkfreq] The default check frequency for all groups on the csync2 hosts
#
# First you will need to define a csync2 GROUP key using csync2 on the command line:
#
# csync2 -k csync2.example.key
#
# Deploy that key with puppet and configure the csync2 class:
#
# class {'csync2': }
#
# csync2::groupnode { $::fqdn:
#   group      => 'default', }
#
# csync2::group { 'default':
#   includes   => ['/tmp/example/path1', '/tmp/example/path2'],
#   excludes   => ['*.svn'],
#   auto       => 'younger',
#   group_key  => 'example',
#   key_source => 'puppet:///modules/csync2/keys/csync2.example.key',
# }

class csync2 (
  $ensure          = 'present',
  $checkfreq       = $::csync2::params::checkfreq,
  $csync2_package  = $::csync2::params::csync2_package,
  $inotify_package = $::csync2::params::inotify_package,
  $csync2_exec     = $::csync2::params::csync2_exec,
  $csync2_config   = $::csync2::params::configfile,
) inherits ::csync2::params {

  #Validate variables
  validate_re($ensure, '^present$|^absent$')
  validate_string($csync2_package)
  validate_string($inotify_package)
  validate_absolute_path($csync2_exec)
  validate_absolute_path($csync2_config)

  #Install the basic packages
  ensure_packages( [$csync2_package, $inotify_package],
    { ensure => $ensure }
  )

  file { '/etc/csync2':
    ensure => directory,
  }

  #Csync2 needs xinetd
  xinetd::service { 'csync2':
    ensure      => $ensure,
    user        => 'root',
    group       => 'root',
    port        => '30865',
    server      => $csync2_exec,
    server_args => '-i',
    flags       => 'REUSE',
    protocol    => 'tcp',
    require     => File['/etc/csync2'],
  }

}
