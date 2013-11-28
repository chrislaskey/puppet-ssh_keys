define ssh_keys::connect (
	$local_user,
	$local_dir = "",
	$target_fqdn = $title,
	$target_port = "22",
	$target_user = $local_user,
	$puppetmaster_key_dir = "/etc/puppet/ssh-keys",
	# This option disables the host key fingerprint check. This is a security
	# hole and should only be used if you know what you are doing. 
	$disable_key_fingerprint_check = "false", # ("false"|"true")
){

	# Include main class
	# ==========================================================================

	include ssh_keys

	if ! empty($local_dir) {
		$parsed_local_dir = $local_dir
	} elsif $local_user == "root" {
		$parsed_local_dir = "/root"
	} else {
		$parsed_local_dir = "/home/${local_user}"
	}

	# Create SSH keys
	# ==========================================================================

	if ! defined(File["${parsed_local_dir}/.ssh"]) {
		file { "${parsed_local_dir}/.ssh":
			ensure => "directory",
			owner => "${local_user}",
			group => "${local_user}",
			mode => "0700",
		}
	}

	file { "${parsed_local_dir}/.ssh/${target_fqdn}":
		ensure => "present",
		content => template("ssh_keys/create-ssh-key"),
		owner => "${local_user}",
		group => "${local_user}",
		mode => "0600",
		require => [
			File["${parsed_local_dir}/.ssh"],
		],
		replace => false, # Do not overwrite content
	}

	# TODO: Fix this, must be partial
	# if ! defined(File["${parsed_local_dir}/.ssh/config"]) {
	#	file { "${parsed_local_dir}/.ssh/config":
	#		ensure => "present",
	#		content => template("ssh_keys/ssh-config"),
	#		owner => "${local_user}",
	#		group => "${local_user}",
	#		mode => "0600",
	#		require => [
	#			File["${parsed_local_dir}/.ssh/${target_fqdn}"],
	#		],
	#	}
	# }

}
