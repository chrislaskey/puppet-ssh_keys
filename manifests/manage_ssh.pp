class ssh_keys::manage_ssh {

  include ssh_keys::params

  ensure_packages([
    $ssh_keys::params::ssh_server_package,
    $ssh_keys::params::ssh_client_package,
  ])

  service { $ssh_keys::params::ssh_service:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      Package[$ssh_keys::params::ssh_client_package],
      Package[$ssh_keys::params::ssh_server_package],
    ]
  }

}
