# = Class: selenium::chrome
#
# Manages the selenium::chrome webdriver
# Parameters:
#
#  [*version*]
#    The version of chrome driver
#
#  [*target_install*]
#    The path where install chrome driver
#
#  [*from_repo*]
#    Install chrome from official repo
#

class selenium::chrome(
  $version        = "2.10",
  $target_install = '/usr/local/bin',
  $from_repo      = false
) {
  $source_file           = "chromedriver_linux64.zip"
  $source_url            = "http://chromedriver.storage.googleapis.com/${version}/${source_file}"
  $target_dir            = '/opt/chromedriver'
  $chrome_url_deb        = 'http://mirror.pcbeta.com/google/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_41.0.2272.118-1_amd64.deb'
  $chrome_destination    = '/tmp/google-chrome.deb'

  ensure_packages(['unzip'])

  file { $target_dir:
    ensure => 'directory',
    path   => $target_dir,
  }

  wget::fetch { 'chrome-driver':
    source      => $source_url,
    destination => "${target_dir}/${source_file}",
  }->
  exec { "unzip -u ${source_file}":
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    cwd     => '/opt/chromedriver',
    require => Package['unzip'],
  }

  file { "${target_install}/chromedriver":
    ensure => link,
    target => "${target_dir}/chromedriver",
  }

  if $from_repo {
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
  } else {
    # Install a specific version from deb
    wget::fetch { 'google-chrome':
      source      => $chrome_url_deb,
      destination => "${chrome_destination}",
    }->
    package { 'libxss1':
      ensure => installed,
    }->
    package { 'libappindicator1':
      ensure => installed,
    }->
    package { 'xdg-utils':
      ensure => installed,
    }->
    package { "google-chrome":
      provider => dpkg,
      ensure   => latest,
      source   => "${chrome_destination}"
    }
  }
}
