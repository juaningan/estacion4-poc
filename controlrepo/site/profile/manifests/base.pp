class profile::base {
  file { '/tmp/hola':
    content => 'mundo',
  }
}
