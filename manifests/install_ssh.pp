class ssh_keys::install_ssh {

	# Set variables

	case $::osfamily {
		"debian": {
			$ssh_server_package = 'openssh-server'
			$ssh_client_package = 'openssh-client'
			$ssh_service = 'ssh'
		}
		"redhat": {
			$server_package_name = 'openssh-server'
			$client_package_name = 'openssh-clients'
			$ssh_service = 'sshd'
		}
		default: {
			fail("The sshkeys puppet module only supports debian and redhat family distributions. Your distribution is: ${::osfamily}/${::operatingsystem}")
		}
	}

	# Install packages

	package { "${ssh_client_package}": 
		ensure => "present",
	}

	package { "${ssh_server_package}": 
		ensure => "present",
	}

	# Ensure service is running

	service { "${ssh_service}":
		enable     => "true",
		ensure     => "running",
		hasrestart => "true",
		hasstatus  => "true",
		require    => [
			Package["${ssh_client_package}"],
			Package["${ssh_server_package}"],
		]
	}

}
