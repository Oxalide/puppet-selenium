# Class: selenium
#
# This module manages the selenium standlone server
#
# Parameters:
#
#  [*user*]
#    The user alloed to launch selenium server
#
#  [*group*]
#    The group alloed to launch selenium server
#
#  [*install_root*]
#    The directory where install selenium
#
#  [*java*]
#    The name of java bin
#
#  [*install_java*]
#    Ensure if java should be installed
#
#  [*version*]
#    The version of selenium to be installed
#
#  [*port*]
#    The port to be used by selenium
#
#  [*url*]
#    The url to be used by selenium
#
#  [*download_timeout*]
#    Timeout used when downloading selenium binary
#
#  [*nocheckcertificate*]
#    Check the selenium binary certifcate
#
#  [*with_chrome_driver*]
#    Install and enable chrome driver for selenium
#

class selenium(
  $user               = $selenium::params::user,
  $group              = $selenium::params::group,
  $install_root       = $selenium::params::install_root,
  $java               = $selenium::params::java,
  $install_java       = $selenium::params::install_java,
  $version            = $selenium::params::version,
  $port               = $selenium::params::port,
  $url                = undef,
  $download_timeout   = $selenium::params::download_timeout,
  $nocheckcertificate = false,
  $with_chrome_driver = false,
) inherits selenium::params {
  validate_string($user)
  validate_string($group)
  validate_string($install_root)
  validate_string($java)
  validate_string($version)
  validate_string($url)
  validate_string($download_timeout)
  validate_bool($nocheckcertificate)
  validate_bool($install_java)
  validate_bool($with_chrome_driver)

  include wget

  user { $user:
    gid    => $group,
  }
  group { $group:
    ensure => present,
  }

  if $install_java {
    class {'java':
      distribution => 'jdk'
    }
  }

  $jar_name     = "selenium-server-standalone-${version}.jar"
  $path_version = regsubst($version, '^(\d+\.\d+)\.\d+$', '\1')

  if $url {
    $jar_url = $url
  } else {
    $variant = "${path_version}/${jar_name}"
    $jar_url = "https://selenium-release.storage.googleapis.com/${variant}"
  }

  File {
    owner => $user,
    group => $group,
  }

  file { $install_root:
    ensure => directory,
  }

  $jar_path = "${install_root}/jars"
  $log_path = "${install_root}/log"

  file { $jar_path:
    ensure => directory,
  }

  file { $log_path:
    ensure => directory,
    mode   => '0755',
  }

  file { '/var/log/selenium':
    ensure => link,
    owner  => 'root',
    group  => 'root',
    target => $log_path,
  }

  wget::fetch { 'selenium-server-standalone':
    source             => $jar_url,
    destination        => "${jar_path}/${jar_name}",
    timeout            => $download_timeout,
    nocheckcertificate => $nocheckcertificate,
    execuser           => $user,
    require            => File[$jar_path],
  }

  logrotate::rule { 'selenium':
    path          => $log_path,
    rotate_every  => 'weekly',
    missingok     => true,
    rotate        => '4',
    compress      => true,
    delaycompress => true,
    copytruncate  => true,
    minsize       => '100k',
  }

  # Add google chrome signing key
  $google_chrome_repo_name     = 'google-chrome'
  $google_chrome_repo_gpg_key  = 'http://dl-ssl.google.com/linux/linux_signing_key.pub'
  case $::osfamily {
    'RedHat': {
      yumrepo { $google_chrome_repo_name:
        enabled  => 1,
        gpgcheck => 1,
        baseurl  => 'http://dl.google.com/linux/chrome/rpm/stable/$basearch',
        gpgkey   => $google_chrome_repo_gpg_key,
      }
    }
    'Debian': {
      apt::source { $google_chrome_repo_name:
        location          => 'http://dl.google.com/linux/chrome/deb/',
        release           => 'stable',
        key_source        => $google_chrome_repo_gpg_key,
        key               => '7FAC5991',
        repos             => 'main',
        include_src       => false,
      }
    }
  }->
  package { "${google_chrome_repo_name}-stable":
    ensure => installed,
  }


  if ! defined(Package['openjdk-7-jre']) {
    package { 'openjdk-7-jre':
      ensure => installed,
    }
  }

  if ! defined(Package['xvfb']) {
    package { 'xvfb':
      ensure => installed,
    }
  }

  if $with_chrome_driver {
    include selenium::chrome
  }
}
