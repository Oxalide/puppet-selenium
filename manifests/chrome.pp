# = Class: selenium::chrome
#
# Manages the selenium::chrome webdriver
#
class selenium::chrome(
  $version = "2.10",
  $target_install = '/usr/local/bin'
) {
  $source_file           = "chromedriver_linux64.zip"
  $source_url            = "http://chromedriver.storage.googleapis.com/${version}/${source_file}"
  $target_dir            = '/opt/chromedriver'

  file { $target_dir:
    ensure => 'directory',
    path   => $target_dir,
  }

  # Todo chrome browser

  wget::fetch { 'chrome-driver':
    source      => $source_url,
    destination => "${target_dir}/${source_file}",
  }->
  exec { "unzip -u ${source_file}":
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    cwd     => '/opt/chromedriver',
  }

#  puppi::project::archive { 'chromedriver':
#    source      => $source_url,
#    deploy_root => $target_install,
#    auto_deploy => true,
#    enable      => true,
#  }

  file { "${target_install}/chromedriver":
    ensure => link,
    target => "${target_dir}/chromedriver",
  }
}
