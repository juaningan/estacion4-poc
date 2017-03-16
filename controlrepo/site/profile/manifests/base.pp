class profile::base {
  package { 'bash' :
    ensure => '4.2.46-20.el7_2',
    #ensure => '4.2.46-21.el7_3',
  }
}
