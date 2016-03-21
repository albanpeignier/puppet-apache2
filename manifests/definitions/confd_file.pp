define apache2::confd_file($source = '', $content = false, $version = 22) {
  $real_name = $version ? {
    22 => $name,
    24 => "$name.conf"
  }
  if $content {
    file { "/etc/apache2/conf.d/$real_name":
      content => $content,
      notify => Service[apache2],
      require => Package[apache2]
    }
  } else {
    $real_source = $source ? {
      '' => ["puppet:///files/apache2/conf.d/$name.$fqdn", "puppet:///files/apache2/conf.d/$name", "puppet:///apache2/conf.d/$name"],
      default => $source
    }
  
    file { "/etc/apache2/conf.d/$real_name":
      source => $real_source,
      notify => Service[apache2],
      require => Package[apache2]
    }
  }

  if $version == 24 {
    exec { "enable_conf_$name":
      command => "/usr/sbin/a2enconf $name.conf",
      require => File["$name.conf"]
    }
  }
}
