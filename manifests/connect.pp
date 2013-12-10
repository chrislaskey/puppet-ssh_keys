define ssh_keys::connect (
	# Expected $title value is "local_user:remote_user@remote_fqdn"
	$ensure = "present", # Expected values: "present" or "absent". Note: absent removes key pair from both the client and Puppet Master storage.
	$store_key = true,
	$ssh_key_directory = "", # Local directory to store the private key. Defaults to home directory of the user, /home/user/.ssh or /root/.ssh.
){

	# Setup environment
	# ==========================================================================

	include ssh_keys
	include ssh_keys::params

	# Set local variables

	$puppetmaster_key_dir = $ssh_keys::params::puppetmaster_key_dir
	$removed_keys_dir = "${puppetmaster_key_dir}/removed-keys"
	$removed_key_file = "${removed_keys_dir}/${title}"

	$store_private_key = str2bool($store_key)
	$update_private_key_value_each_run = $store_private_key # If private key is stored on Puppet Master, always rewrite value. Otherwise, only write on key creation.
	$ensure_private_key = $ensure ? {
		"absent" => "absent",
		default  => "present",
	}

	$pieces = parse_sshkey_connection($title) # Parse $title into local_user:remote_user@remote_fqdn
	if empty($pieces) {
		fail("Invalid ssh_keys::connect definition. The \$title attribute must be in the form of local_user:remote_user@remote_fqdn. Received attribute \"${title}\".")
	}
	$local_user = $pieces["local_user"]
	$local_fqdn = $::fqdn
	$target_user = $pieces["remote_user"]
	$target_fqdn = $pieces["remote_fqdn"]
	$target_user_and_fqdn = "${target_user}@${target_fqdn}"

	# Set local home directory

	if ! empty($ssh_key_directory) {
		$key_dir = $ssh_key_directory
	} elsif $local_user == "root" {
		$key_dir = "/root/.ssh"
	} else {
		$key_dir = "/home/${local_user}/.ssh"
	}

	# Create SSH keys
	# ==========================================================================

	if ! defined(File["${key_dir}"]) {
		file { "${key_dir}":
			ensure => "directory",
			owner => "${local_user}",
			group => "${local_user}",
			mode => "0700",
		}
	}

	file { "${key_dir}/${target_user_and_fqdn}":
		ensure => $ensure_private_key,
		content => template("ssh_keys/create-ssh-key"),
		owner => "${local_user}",
		group => "${local_user}",
		mode => "0600",
		replace => $update_private_key_value_each_run,
		require => [
			File["${key_dir}"],
		],
	}

	if $ensure_private_key == "absent" {
		file { "${removed_keys_dir}":
			ensure => "directory",
			owner => "puppet",
			group => "puppet",
			mode => "0600",
			require => [
				File["${key_dir}/${target_user_and_fqdn}"],
			],
		}

		file { "${removed_key_file}":
			ensure => "present",
			content => template("ssh_keys/remove-ssh-key"),
			owner => "puppet",
			group => "puppet",
			mode => "0600",
			require => [
				File["${removed_keys_dir}"],
			],
		}
	}

}
