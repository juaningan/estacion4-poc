Exec {
  path      => $facts['path'],
  logoutput => 'on_failure',
}

include lookup('role')
