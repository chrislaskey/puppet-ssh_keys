About
================================================================================

A custom puppet module for automating SSH key creation and deployment between
source and target machines.

Example
-------

On the source machine define as many ssh_keys as needed. Below is a list of
parameters and their default values:

	ssh_keys::create { "deploy":
		target_fqdn => $puppetmaster_fqdn,
		target_port => "2222",
		target_ssh_user => "deploy",
		disable_key_fingerprint_check => "false",
  	  	general_key_dir => "/data/ssh-keys",
	}

The target machine:

	class { "ssh_keys::authorize":
  	  	general_key_dir => "/data/ssh-keys",
	}

**Note** since ```ssh_keys::authorize``` is a class, it only needs to be
called once per node, unlike ```ssh_keys::create``` which requires a definition
for each key pair.

File Server Setup
-----------------

A custom Puppet File Server location is required on the Puppet Master. Add
a ```[ssh-keys]``` entry to ```/etc/puppet/fileserver.conf```. The recommended
entry is:

  	[ssh-keys]
      	path /data/ssh-keys/%H
      	allow *

This stores the public keys in the default location, ```/data/ssh-keys/<target-fqdn>```.

If using a path other than ```/data/ssh-keys```, make sure to pass in the new
location as a parameter in the node definitions:

	class { "ssh_keys::authorize":
		general_key_dir => "/new/path/here"
	}

	ssh_keys::create { "deploy":
  	  	general_key_dir => "/new/path/here",
	}

**Note** the ```general_key_dir``` parameter should only be passed if using
something other than the default ```/data/ssh-keys``` directory.

For more information on Puppet File Servers see the [Puppet
Documentation](https://github.com/puppetlabs/puppet-docs/blob/master/source/guides/file_serving.markdown).

How it works
------------

The source machine (holder of the private key) runs the Puppet catalog. A new
SSH key pair is created on the Puppet Master. The Puppet Master stores the
public key, and the private key is transferred to the source machine's
```/home/<user>/.ssh``` directory and immediately removed from the Puppet
Master. The Puppet Master also creates a ```/home/<user>/.ssh/config``` file
for the target machine's fqdn.

The target machine (holder of the public key) runs the Puppet catalog. The
Puppet Master pushes the public keys related to the target machine, identified
by the machine's fully qualified domain name (FQDN). The target machine then
processes the public keys and adds each to the target users
``/home/<user>/.ssh/authorized_keys``` file. This process is idempotent.

Implications
------------

For security private keys are never stored on the Puppet Master or anywhere
except the source machine.

Once a key pair is created, subsequent catalog runs can not confirm the
contents of the private key. As a result **this process requires synchronizing
the execution of the Puppet catalog runs: Source Machine >> Target Machine**.

If the manifests are run out of order, remove the key pairs from the source
machine and the Puppet Master. There is no need to remove files from the target
machine. Then apply the Puppet catalogs again in the correct order.

Known Hosts
-----------

The last step in the SSH handshake is the ```/home/<user>/.ssh/known_hosts``` file.

There is no automated way to accept the fingerprint of an SSH key. There are two
solutions, the first is to manually connect from the source machine to the
target machine and accept the fingerprint.

The second is to use the ```disable_key_fingerprint_check``` attribute in the
```ssh_keys::create``` definition. The latter option is only recommended for
advanced users as it will discard the known host check and opens the door for
man-in-the-middle attack vectors.

License
================================================================================

All code written by me is released under MIT license. See the attached
license.txt file for more information, including commentary on license choice.
