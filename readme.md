About
================================================================================

The `ssh_keys` module automates SSH key management in Puppet. It provides a
simple interface for configuring and managing per-user key-based SSH
connections between hosts.

```puppet
	# A nodes.pp file

	node "source-machine" {
		ssh_keys::connect { "john:john@target-machine.example.com": }
		ssh_keys::connect { "sarah:deploy@target-machine.example.com": }
	}

	node "target-machine" {
		include ssh_keys::authorize
	}
```

Defining a connection is as simple as a `ssh_keys::connect` definition on the
source machine and a `ssh_keys::authorize` class on the target machine. The SSH
key pairs are created, the `known_hosts` files populated, and the
`authorized_keys` file updated.

Each connection uses a separate key-pair, minimizing the security risk of
a compromised key while automating away the maintenance.

Connecting from the `source-machine` to `target-machine` is now as simple as:

```bash
	john@source-machine$ ssh -i ~/.ssh/john@target-machine target-machine
	sarah@source-machine$ ssh -i ~/.ssh/deploy@target-machine deploy@target-machine
```

Installation Requirements
-------------------------

The `ssh_keys` module has the following dependencies:

- Puppet modules `puppetlabs/stdlib` and `chrislaskey/ipaddresses`
- Puppet filebucket
- PuppetDB

Installation of PuppetDB and custom modules is straight forward. Configuring
the filebucket is as simple as adding:

  	[ssh-keys]
      	path /etc/puppet/ssh-keys/public/%H
      	allow *

To the bottom of the `/etc/puppet/fileserver.conf` on the Puppet Master.

License
================================================================================

All code written by me is released under MIT license. See the attached
license.txt file for more information, including commentary on license choice.
