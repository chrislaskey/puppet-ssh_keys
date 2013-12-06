About
================================================================================

A custom puppet module for automating SSH key creation and deployment between
source and target machines.

Example
-------

On the source machine define as many ssh_keys as needed. Below is a list of
parameters and their default values:

	ssh_keys::create { "remote-target.example.com":
		local_user => "deploy",
		target_port => "22",
		target_user => "deploy",
		disable_key_fingerprint_check => "false",
  	  	puppet_key_dir => "/data/ssh-keys",
	}

The target machine:

	class { "ssh_keys::authorize":
  	  	puppet_key_dir => "/data/ssh-keys",
	}

**Note** since `ssh_keys::authorize` is a class, it only needs to be
called once per node, unlike `ssh_keys::create` which requires a definition
for each key pair.

File Server Setup
-----------------

A custom Puppet File Server location is required on the Puppet Master. Add
a `[ssh-keys]` entry to `/etc/puppet/fileserver.conf`. The recommended
entry is:

  	[ssh-keys]
      	path /etc/puppet/ssh-keys/%H
      	allow *

This stores the public keys in the default location `/etc/puppet/ssh-keys/<target-fqdn>`.

If using a path other than `/etc/puppet/ssh-keys` make sure to pass in the new
location as a parameter in the node definitions:

	class { "ssh_keys::authorize":
		puppet_key_dir => "/new/path/here"
	}

	ssh_keys::create { "deploy":
  	  	puppet_key_dir => "/new/path/here",
	}

**Note** the `puppet_key_dir` parameter should only be passed if using
something other than the default `/etc/puppet/ssh-keys` directory.

For more information on Puppet File Servers see the [Puppet
Documentation](https://github.com/puppetlabs/puppet-docs/blob/master/source/guides/file_serving.markdown).

How it works
------------

The source machine (holder of the private key) runs the Puppet catalog. A new
SSH key pair is created on the Puppet Master. The Puppet Master stores the
public key, and the private key is transferred to the source machine's
`/home/<user>/.ssh` directory and immediately removed from the Puppet
Master. The Puppet Master also creates a `/home/<user>/.ssh/config` file
for the target machine's fqdn.

The target machine (holder of the public key) runs the Puppet catalog. The
Puppet Master pushes the public keys related to the target machine, identified
by the machine's fully qualified domain name (FQDN). The target machine then
processes the public keys and adds each to the target users
``/home/<user>/.ssh/authorized_keys` file. This process is idempotent.

Regenerating Keys
-----------------

Once a key pair is created, subsequent catalog runs can not confirm the
contents of the private key.

Though more secure, a side effect of this is the Puppet Master can not
determine when a key pair has changed.

To regenerate a key pair manually remove the private key file on the source
machine. Then run Puppet on the source machine. Finally, run Puppet on the
target machine.

Troubleshooting
---------------

If the following error pops up when executing a `ssh_keys::connect` definition:

  err: Could not retrieve catalog from remote server: wrong header line format

Check the permissions on the Puppet Master for the `ssh_keys::params::puppet_key_dir` (default
location is `/etc/puppet/ssh-keys`). It may require manually creating the key directory:

  mkdir -p /etc/puppet/ssh-keys
  chown -R puppet:puppet /etc/puppet/ssh-keys

License
================================================================================

All code written by me is released under MIT license. See the attached
license.txt file for more information, including commentary on license choice.
