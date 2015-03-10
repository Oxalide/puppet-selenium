# = Class: selenium::chrome
#
# Manages the selenium::chrome webdriver
#
class selenium::chrome(
  $version = "2.10",
  $target_install = '/usr/local/bin'
) {
  $source_file           = "chromedriver_linux32.zip"
  $source_url            = "http://chromedriver.storage.googleapis.com/${version}/${source_file}"
  $exec_name             = 'chromedriver'
  $target_dir            = '/opt'

  puppi::project::archive { 'chromedriver':
    source      => $source_url,
    deploy_root => $target_dir,
    auto_deploy => true,
    enable      => true,
  }

  file { 'chromedriver_link':
    ensure => "${target_dir}/chromedriver",
    path   => "${target_install}/chromedriver",
  }
}
