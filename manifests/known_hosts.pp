class ssh_keys::known_hosts {

	# Fix known /etc/ssh/ssh_known_hosts permissions bug:
	# http://projects.puppetlabs.com/issues/2014

	file { "/etc/ssh/ssh_known_hosts":
		ensure => "file",
		owner  => "root",
		group  => "root",
		mode   => "0644",
	}

	# Export the host's keys

	$all_ips = ipaddresses()
	$all_ips_no_local = delete($all_ips, "lo")
	$host_aliases = unique(values($all_ips_no_local))
	
	# A pure Puppet implementation. Less dynamic, but requires no custom
	# functions, facts or modules.
	#
	# $possible_host_aliases = [
	# 	$::fqdn,
	# 	$::hostname,
	# 	empty($::ipaddress_eth0) ? { true => "none", false => $::ipaddress_eth0},
	# 	empty($::ipaddress_eth1) ? { true => "none", false => $::ipaddress_eth1},
	# 	empty($::ipaddress_eth2) ? { true => "none", false => $::ipaddress_eth2},
	# 	empty($::ipaddress_eth3) ? { true => "none", false => $::ipaddress_eth3},
	# 	empty($::ipaddress_eth4) ? { true => "none", false => $::ipaddress_eth4},
	# 	empty($::ipaddress_eth5) ? { true => "none", false => $::ipaddress_eth5},
	# 	empty($::ipaddress_eth6) ? { true => "none", false => $::ipaddress_eth6},
	# 	empty($::ipaddress_en0) ? { true => "none", false => $::ipaddress_en0},
	# 	empty($::ipaddress_en1) ? { true => "none", false => $::ipaddress_en1},
	# 	empty($::ipaddress_en2) ? { true => "none", false => $::ipaddress_en2},
	# 	empty($::ipaddress_en3) ? { true => "none", false => $::ipaddress_en3},
	# ]
	# $host_aliases = delete($possible_host_aliases, "none")

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
