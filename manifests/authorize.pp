class ssh_keys::authorize(
	$general_key_dir = "/data/ssh-keys",
){

	# Class variables
	# ==========================================================================

	$target_fqdn_key_dir = "${general_key_dir}/${fqdn}"

	# Send keys
	# ==========================================================================

	file { "${general_key_dir}":
		ensure => "directory",
		owner => "puppet",
		group => "puppet",
		mode => "0700",
		require => [
			File["/data/puppet"],
		]
	}

	file { "${target_fqdn_key_dir}":
		# See /etc/puppet/fileserver.conf 
		# and https://github.com/puppetlabs/puppet-docs/blob/master/source/guides/file_serving.markdown  
		# for source property. This example maps to $target_fqdn_key_dir value.
		source => "puppet:///ssh-keys",
		owner => "puppet",
		group => "puppet",
		mode => "0600",
		recurse => true, # Transfer directory files too
		purge => true, # Remove client files not found on puppetmaster dir
		require => [
			File["${general_key_dir}"],
		],
	}

	# Authorize keys
	# ==========================================================================

	file { "${general_key_dir}/authorize-ssh-keys.sh":
		ensure => "present",
		content => template("ssh_keys/authorize-ssh-keys"),
		owner => "puppet",
		group => "puppet",
		mode => "0700",
		require => [
			File["${target_fqdn_key_dir}"],
		],
	}

	exec { "authorize-ssh-keys": 
		command => "${general_key_dir}/authorize-ssh-keys.sh",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		user => "root",
		group => "root",
		logoutput => "on_failure",
		require => [
			File["${general_key_dir}/authorize-ssh-keys.sh"],
		],
	}

}
