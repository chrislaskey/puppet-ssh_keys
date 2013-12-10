class ssh_keys::params {

  # For ssh_keys::authorize
  # ==========================================================================

  # Where public keys are stored on clients and puppet master
  $puppet_key_dir = '/etc/puppet/ssh-keys'

  # For ssh_keys::connect
  # ==========================================================================

  $puppetmaster_key_dir = '/etc/puppet/ssh-keys'

  # For ssh_keys::install_ssh
  # ==========================================================================

  case $::osfamily {
    'debian': {
      $ssh_server_package = 'openssh-server'
      $ssh_client_package = 'openssh-client'
      $ssh_service = 'ssh'
    }
    'redhat': {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-clients'
      $ssh_service = 'sshd'
    }
    default: {
      fail("The ssh_keys module only supports Debian and Redhat family
      distributions. Your distribution is: ${::osfamily}/${::operatingsystem}")
    }
  }


}
