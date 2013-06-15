define ssh_keys::create (
	$target_fqdn,
	$target_port = "22",
	$target_ssh_user = $title,
	$local_ssh_user = $title,
	$general_key_dir = "/data/ssh-keys",
	
	# This option disables the key fingerprint check. This is a security hole
	# and should only be used if you know what you are doing. The main use
	# case is headless scripts using unmonitored users.
	$disable_key_fingerprint_check = "false", # ("false"|"true")
){

	# Class variables
	# ==========================================================================

	$puppetmaster_key_dir = $general_key_dir
	$local_home_dir = "/home/${local_ssh_user}"

	# Create SSH keys
	# ==========================================================================

	file { "${local_home_dir}/.ssh":
		ensure => "directory",
		owner => "${local_ssh_user}",
		group => "${local_ssh_user}",
		mode => "0700",
	}

	file { "${local_home_dir}/.ssh/${target_fqdn}":
		ensure => "present",
		content => template("ssh_keys/create-ssh-key"),
		owner => "${local_ssh_user}",
		group => "${local_ssh_user}",
		mode => "0600",
		require => [
			File["${local_home_dir}/.ssh"],
		],
		replace => false, # Do not overwrite content
	}

	file { "${local_home_dir}/.ssh/config":
		ensure => "present",
		content => template("ssh_keys/ssh-config"),
		owner => "${local_ssh_user}",
		group => "${local_ssh_user}",
		mode => "0600",
		require => [
			File["${local_home_dir}/.ssh/${target_fqdn}"],
		],
	}

}
