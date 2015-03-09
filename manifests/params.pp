# == Class: selenium::params
#
# This class should be considered private.
#
#
class selenium::params {
  $display          = ':0'
  $user             = 'selenium'
  $group            = $user
  $install_root     = '/opt/selenium'
  $server_options   = '-Dwebdriver.enable.native.events=1'
  $hub_options      = '-role hub'
  $node_options     = "${server_options} -role node"
  $install_java     = false
  $java             = 'java'
  $version          = '2.44.0'
  $port             = 4444
  $default_hub      = "http://localhost:${port}/grid/register"
  $download_timeout = '90'

  case $::osfamily {
    'redhat': {}
    'Debian': {}
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

}
