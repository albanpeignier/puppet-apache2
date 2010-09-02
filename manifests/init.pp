import "classes/*.pp"
import "definitions/*.pp"

class apache2 {

  package { apache2-mpm-worker: 
    alias => apache2,
    ensure => installed 
  }

  service { apache2:
    ensure    => running,
    subscribe => File["/etc/apache2"],
    require => Package[apache2],
    hasrestart => true
  }

  # configuration de base (log, ...)
  confd_file { ["base","log","serverstatus"]: }

  # reduce apache2 log storage
  file { "/etc/logrotate.d/apache2":
    source => "puppet:///apache2/apache2.logrotate"
  }

  # histoire de reloader apache2 quand la conf change
  # fonctionne partiellement
  file { "/etc/apache2":
    ensure => directory,
    recurse => true
  }

  file { "/etc/apache2/users":
    mode => 640,
    owner => www-data,
    group => adm,
    ensure => present
  }

  file { ["/var/www","/var/www/default"]:
    ensure => directory
  }
  file { "/var/www/default/index.html":
    ensure => present
  }

  site { "default":
    link => "000-default",
    require => File["/var/www/default"],
    source => "puppet:///apache2/default.conf"
  }

  if $apache_server_admin {
    file { "/etc/apache2/conf.d/server_admin":
      content => "ServerAdmin $apache_server_admin\n",
      notify => Service[apache2],
      require => Package[apache2]
    }
  }

  include apache2::munin
}

class apache2::munin {

  munin::plugin {
    [apache_accesses, apache_processes, apache_volume]:
    require => Package[libwww-perl]
  }
  package { libwww-perl: }

}
