class ssh_keys () {

  include ssh_keys::known_hosts
  include ssh_keys::manage_ssh

}
