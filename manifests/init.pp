class ssh_keys (
	$install_ssh_packages = true,
	$add_known_hosts = true,
){

	if $install_ssh_packages {
		include ssh_keys::install_ssh
	}

	if $add_known_hosts {
		include ssh_keys::known_hosts
	}

}
