# apc

#== Class: apc
#
#Installs APC Support with basic configuration.
#Depends on (tested with)
# - https://github.com/camptocamp/puppet-apache.git
# - https://github.com/camptocamp/puppet-php.git
#
#Example usage:
#
#  include apc
#
#  with parameter overrides:
#
#  class{'::apc':
#    param => 'value',
#  }
#
#Configuration:
#
#  - edit params.pp to change default values
#  - add new values to augeas-command in config.pp
#

class apc (
  $enabled                      = $::apc::params::enabled,
  $shmsize                      = $::apc::params::shmsize,
  $shmsegments                  = $::apc::params::shmsegments,
  $ttl                          = $::apc::params::ttl,
  $stat                         = $::apc::params::stat,
  $canonicalize                 = $::apc::params::canonicalize,
  $include_once_override        = $::apc::params::include_once_override,
  $rfc1867                      = $::apc::params::rfc1867,
  $mmap_file_mask               = $::apc::params::mmap_file_mask,
  $enable_cli                   = $::apc::params::enable_cli,
  $php_version                  = $::apc::params::php_version,
  $apcu_backwards_compatibility = $::apc::params::apcu_backwards_compatibility,
) inherits ::apc::params {

  case $php_version {
    '5.3': {
      $pkg = $::operatingsystem ? {
        /Debian|Ubuntu/ => 'php-apc',
        'CentOS'          => 'php-pecl-apc',
      }

      $conf = $::operatingsystem ? {
        /Debian|Ubuntu/ => '/etc/php5/apache2/conf.d/apc.ini/',
        'CentOS'          => '/etc/php.d/apc.ini/',
      }
    }
    #install apcu instead of apc for php versions other than 5.3
    '5.4': {
      $pkg = $::operatingsystem ? {
        /Debian|Ubuntu/ => 'php-apc',
        'CentOS'          => 'php-pecl-apcu',
      }

      $conf = $::operatingsystem ? {
        /Debian|Ubuntu/ => '/etc/php5/apache2/conf.d/apc.ini/',
        'CentOS'          => '/etc/php.d/apcu.ini/',
      }
    }
    #install apcu instead of apc for php versions other than 5.3
    '5.5', '5.6': {
      $pkg = $::operatingsystem ? {
        /Debian|Ubuntu/ => 'php-apc',
        'CentOS'          => 'php-pecl-apcu',
      }

      $conf = $::operatingsystem ? {
        /Debian|Ubuntu/ => '/etc/php5/apache2/conf.d/apc.ini/',
        'CentOS'          => '/etc/php.d/apcu.ini',
      }
    }
    '7.0': {
      $pkg = $::operatingsystem ? {
        /Debian|Ubuntu/ => 'php-apc',
        'CentOS'          => 'php-pecl-apcu',
      }

      $conf = $::operatingsystem ? {
        /Debian|Ubuntu/ => '/etc/php5/apache2/conf.d/apc.ini/',
        'CentOS'          => '/etc/php.d/40-apcu.ini',
      }

      $backwards_compatibility_pkg = $::operatingsystem  ? {
        'CentOS' => 'php-pecl-apcu-bc',
      }
    }
    default:{
      fail "Unsupported PHP version: ${php_version}" }
  }

  case $::operatingsystem {
    'Debian','Ubuntu','CentOS':  {
      class { 'apc::config':
        conf                         => $conf,
        pkg                          => $pkg,
        apcu_backwards_compatibility => $apcu_backwards_compatibility,
        backwards_compatibility_pkg  => $backwards_compatibility_pkg,
      }
    }
    default: {
      fail "Unsupported operatingsystem: ${::operatingsystem}"
    }
  }

}
