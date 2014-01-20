# Expected $title value: "local_user:remote_user@remote_fqdn"
#
# Expected $store_key values: "present" or "absent". Note: absent removes key
# pair from both the client and Puppet Master storage.
#
# Expected $ssh_key_directory: Local directory to store the private key.
# Defaults to home directory of the user, /home/user/.ssh or /root/.ssh.

define ssh_keys::connect (
  $ensure            = 'present',
  $store_key         = true,
  $manage_ssh_config = true,
  $ssh_key_directory = '',
){

  # Setup environment
  # ==========================================================================

  include ssh_keys
  include ssh_keys::params

  # Set local variables

  $puppetmaster_key_dir = $ssh_keys::params::puppetmaster_key_dir
  $removed_keys_dir     = "${puppetmaster_key_dir}/removed-keys"
  $removed_key_file     = "${removed_keys_dir}/${title}"
  $store_private_key    = str2bool($store_key)

  # If private key is stored on Puppet Master, always rewrite value. Otherwise,
  # only write on key creation.
  $update_private_key_value_each_run = $store_private_key

  $ensure_private_key = $ensure ? {
    'absent' => 'absent',
    default  => 'present',
  }

  # Parse $title into local_user:remote_user@remote_fqdn
  $pieces = parse_sshkey_connection($title)
  if empty($pieces) {
    fail("Invalid ssh_keys::connect definition. The \$title attribute must be
    in the form of local_user:remote_user@remote_fqdn. Received attribute
    '${title}'.")
  }

  $local_user                   = $pieces['local_user']
  $local_fqdn                   = $::fqdn
  $target_user                  = $pieces['remote_user']
  $target_fqdn                  = $pieces['remote_fqdn']
  $target_user_and_fqdn         = "${target_user}@${target_fqdn}"
  $target_user_and_fqdn_with_at = "${target_user}-at-${target_fqdn}"

  # Set local home directory

  if ! empty($ssh_key_directory) {
    $key_dir = $ssh_key_directory
  } elsif $local_user == 'root' {
    $key_dir = '/root/.ssh'
  } else {
    $key_dir = "/home/${local_user}/.ssh"
  }

  $key_file = "${key_dir}/${target_user_and_fqdn}"

  # Create SSH keys
  # ==========================================================================

  if ! defined(File[$key_dir]) {
    file { $key_dir:
      ensure => 'directory',
      owner  => $local_user,
      group  => $local_user,
      mode   => '0700',
    }
  }

  file { $key_file:
    ensure  => $ensure_private_key,
    content => template('ssh_keys/create-ssh-key'),
    owner   => $local_user,
    group   => $local_user,
    mode    => '0600',
    replace => $update_private_key_value_each_run,
    require => File[$key_dir],
  }

  if $ensure_private_key == 'absent' {
    file { $removed_keys_dir:
      ensure  => 'directory',
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      require => File[$key_file],
    }

    file { $removed_key_file:
      ensure  => 'present',
      content => template('ssh_keys/remove-ssh-key'),
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0600',
      require => File[$removed_keys_dir],
    }
  }

  # Create SSH config fragments
  # ==========================================================================

  if $manage_ssh_config {

    if ! defined(Concat["${key_dir}/config"]) {
      concat { "${key_dir}/config":
        owner          => $local_user,
        group          => $local_user,
        mode           => '0644',
        warn           => true,
        force          => true,
        replace        => true,
        ensure_newline => true,
      }
    }

    concat::fragment { "ssh-config-fragment-${target_user_and_fqdn}":
      target  => "${key_dir}/config",
      content => template('ssh_keys/create-ssh-config-fragment'),
    }

  } else {

    file { "${key_dir}/config-example-${target_user_and_fqdn}":
      ensure  => 'present',
      content => template('ssh_keys/create-ssh-config-fragment'),
      owner   => $local_user,
      group   => $local_user,
      mode    => '0644',
      require => File[$key_file],
    }

  }
}
