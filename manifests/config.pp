# == Define: selenium::config
#
# This define should be considered private.
#
define selenium::config(
  $display      = $selenium::params::display,
  $user         = $selenium::params::user,
  $group        = $selenium::params::group,
  $install_root = $selenium::params::install_root,
  $port         = $selenium::port,
  $options      = $selenium::params::server_options,
  $java         = $selenium::params::java,
  $jar_name     = $selenium::jar_name,
) {
  validate_string($display)
  validate_string($user)
  validate_string($group)
  validate_string($install_root)
  validate_string($options)
  validate_string($java)
  validate_string($jar_name)

  # prog is the 'name' of the init.d script.
  $prog = "selenium${name}"

  if ($::osfamily == 'redhat') {
    $template = "${module_name}/init.d/redhat.selenium.erb"
  } elsif ($::osfamily == 'Debian') {
    $template = "${module_name}/init.d/debian.selenium.erb"
  }

  case $::osfamily {
    'redhat', 'Debian': {
      file { "/etc/init.d/${prog}":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template($template),
      }
      ~> exec { 'selenium_systemd_reload':
        command     => 'systemctl daemon-reload',
        path        => '/bin:/usr/bin',
        refreshonly => true,
        onlyif      => 'test -d /run/systemd',
      }
      ~> service { $prog:
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        enable     => true,
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
