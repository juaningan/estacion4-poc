class profile::base {
  package { 'bash' :
    ensure => '4.3-14ubuntu1',
    #ensure => '4.3-11ubuntu1',
  }
}
