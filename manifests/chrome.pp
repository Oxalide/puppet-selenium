# = Class: selenium::chrome
#
# Manages the selenium::chrome webdriver
#
class selenium::chrome(
  $version = "2.10",
  $target_directory = '/usr/local/bin'
) {
  $source_file           = "chromedriver_linux32.zip"
  $source_url            = "http://chromedriver.storage.googleapis.com/${version}/${source_file}"
  $exec_name             = 'chromedriver'

  puppi::project::archive { 'chrome_driver':
    source      => $source_url,
    deploy_root => $target_directory,
    auto_deploy => true,
    enable      => true,
  }

  file { 'chrome_driver_link':
    ensure => $target_directory,
    path   => "${$target_directory}/${$exec_name}",
  }
}
