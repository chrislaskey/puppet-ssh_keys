class ssh_keys::known_hosts () {

	include ssh_keys

	# Fix known /etc/ssh/ssh_known_hosts permissions bug:
	# http://projects.puppetlabs.com/issues/2014

	file { "/etc/ssh/ssh_known_hosts":
		ensure => "file",
		owner  => "root",
		group  => "root",
		mode   => "0644",
	}

	# Parse IPs for host_aliases

	$all_ips = ipaddresses()
	$all_ips_no_local = delete($all_ips, "lo")
	$host_aliases = unique(values($all_ips_no_local))
	
	# Export all host keys
	
	if $::sshecdsakey {
		@@sshkey { "${::fqdn}_ecdsa":
			host_aliases => $host_aliases,
			key          => $::sshecdsakey,
			type         => "ecdsa-sha2-nistp256",
		}
	}

	if $::sshdsakey {
		@@sshkey { "${::fqdn}_dsa":
			host_aliases => $host_aliases,
			key          => $::sshdsakey,
			type         => dsa,
		}
	}

	if $::sshrsakey {
		@@sshkey { "${::fqdn}_rsa":
			host_aliases => $host_aliases,
			key          => $::sshrsakey,
			type         => rsa,
		}
	}

	# Collect other hosts" keys

	Sshkey <<| |>>

}
