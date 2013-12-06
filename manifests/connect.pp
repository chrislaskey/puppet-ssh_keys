define ssh_keys::connect (
	# Expected $title value is "local_user:remote_user@remote_fqdn"
	$ssh_key_directory = "", # Local directory to store the private key. Defaults to home directory of the user, /home/user/.ssh or /root/.ssh.
){

	# Setup environment
	# ==========================================================================

	include ssh_keys
	include ssh_keys::params

	# Set local variables

	$puppetmaster_key_dir = $ssh_keys::params::puppetmaster_key_dir

	$pieces = parse_sshkey_connection($title) # Parse $title into local_user:remote_user@remote_fqdn
	if empty($pieces) {
		fail("Invalid ssh_keys::connect definition. The \$title attribute must be in the form of local_user:remote_user@remote_fqdn. Received attribute \"${title}\".")
	}
	$local_user = $pieces["local_user"]
	$target_user = $pieces["remote_user"]
	$target_fqdn = $pieces["remote_fqdn"]

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

	file { "${key_dir}/${target_fqdn}":
		ensure => "present",
		content => template("ssh_keys/create-ssh-key"),
		owner => "${local_user}",
		group => "${local_user}",
		mode => "0600",
		require => [
			File["${key_dir}"],
		],
		replace => false, # Do not overwrite content
	}

}
