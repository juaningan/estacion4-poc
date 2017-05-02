class profile::winbase {
  windowsfeature { 'Web-WebServer':
    ensure                 => present,
    installmanagementtools => true
  }
}
