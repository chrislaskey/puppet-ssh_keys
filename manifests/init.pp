class ssh_keys (
	# $add_authorize_keys = true,
	# $add_known_hosts = true,
	# $manage_ssh_service = true,
){

	# if $add_known_hosts {
	include ssh_keys::known_hosts
	# }

	# if $add_authorize_keys {
	# include ssh_keys::authorize_keys
	# }

	# if $manage_ssh_service {
	include ssh_keys::manage_ssh
	# }

}
