lxc-create-gentoo
=================

Casually creating cloud computing containers.

This is a series of scripts and templates that, when used with a Gentoo
stage3 tarball and LVM snapshots can used to create lxc containers.

Usage
=====

To spawn a new container, use the lxc-create-gentoo command.

	~ % sudo /etc/lxc/lxc-create-gentoo
	LXC_ROOT is /etc/lxc
	Creating container: 21e722d8
	  Logical volume "21e722d8" created
	INIT: version 2.88 booting

	   OpenRC 0.11.8 is starting up Gentoo Linux (x86_64) [LXC]

	 * /proc is already mounted
	 * /run/openrc: creating directory
	 * /run/lock: creating directory
	 * /run/lock: correcting owner
	 * Caching service dependencies ...
	 [ ok ]
	 * Creating user login records ...
	 [ ok ]
	 * Cleaning /var/run ...
	 [ ok ]
	 * Wiping /tmp directory ...
	 [ ok ]
	 * Updating /etc/mtab ...
	 [ ok ]
	 * Bringing up interface lo
	 *   Caching network module dependencies
	 *   127.0.0.1/8 ...
	 [ ok ]
	 *   Adding routes
	 *     127.0.0.0/8 via 127.0.0.1 ...
	 [ ok ]
	 * Bringing up interface eth0
	 *   No configuration specified; defaulting to DHCP
	 *   dhcp ...
	 *     Running udhcpc ...
	 [ ok ]
	 *     received address 192.168.1.157/24
	 [ ok ]
	 * setting up tmpfiles.d entries ...
	 [ ok ]
	INIT: Entering runlevel: 3
	 * Generating dsa host key ...
	Generating public/private dsa key pair.
	Your identification has been saved in /etc/ssh/ssh_host_dsa_key.
	Your public key has been saved in /etc/ssh/ssh_host_dsa_key.pub.
	The key fingerprint is:
	b6:55:8b:6e:00:ef:75:51:3a:05:5e:ca:d1:18:e0:18 root@21e722d8
	The key's randomart image is:
	+--[ DSA 1024]----+
	|        E ..+=+  |
	|         + o.B.  |
	|      . . . O    |
	|       o   o +   |
	|        S + o    |
	|       o * .     |
	|        o o      |
	|         .       |
	|                 |
	+-----------------+
	 [ ok ]
	 * Generating rsa host key ...
	Generating public/private rsa key pair.
	Your identification has been saved in /etc/ssh/ssh_host_rsa_key.
	Your public key has been saved in /etc/ssh/ssh_host_rsa_key.pub.
	The key fingerprint is:
	ba:24:64:19:ab:68:ac:cb:e7:a7:b0:b4:8f:a4:40:96 root@21e722d8
	The key's randomart image is:
	+--[ RSA 2048]----+
	|                 |
	|                 |
	|    .            |
	|  .  +           |
	| E  =   S        |
	|+. +   .         |
	|o*. . o          |
	|O =. + .         |
	|+*++o .          |
	+-----------------+
	 [ ok ]
	 * Starting sshd ...
	 [ ok ]
	 * Starting local
	 [ ok ]

	21e722d8 login: root (automatic login)
	21e722d8 ~ # 


When the container is stopped (e.g. via lxc-stop in a new shell),
this script will clean up by removing the LVM lv and the lxc control files.

	(new shell) ~ % sudo lxc-stop -n 21e722d8

	(original)
	  Logical volume "21e722d8" successfully removed
	  removed directory: '/etc/lxc/21e722d8/rootfs'
	  removed '/etc/lxc/21e722d8/config'
	  removed directory: '/etc/lxc/21e722d8'


Setting it up
=============

Dependencies
------------
	- sys-fs/lvm2 (With a volume group named 'vg')
	- app-emulation/lxc
	- various kernel things that I won't describe here

Create a clean rootfs
---------------------

	# lvcreate vg -n lxc-clean -L 10G
	# mkfs.ext4 /dev/vg/lxc-clean
	# mkdir -p /mnt/gentoo && mount /dev/vg/lxc-clean /mnt/gentoo
	# cd /mnt/gentoo
	# tar xavpf /path/to/stage3.tar.bz2
	# bash /path/to/fixup-stage3-for-lxc.sh
	# cd - && umount /mnt/gentoo

The LV on vg/lxc-clean can now be snapshotted for quick deploys.

Prepare /etc/lxc
----------------

Copy the contents of the lxc/ directory in this repository to /etc/lxc

Read the /etc/lxc/lxc-create-gentoo script
------------------------------------------

Since it will be run as root, make sure that the script doesn't do anything
too crazy. You have been warned.

Advanced Usage
==============

The container will attach itself to the network bridge `br0` on the host, get IPv4 and IPv6 addresses
and hopefully register itself in DNS. If the network is available and sshd starts, it is possible to
connect to the container (don't forget to verify the ssh fingerprints!). The shell will auto login as
root, so you could set a password but a better approach would be to use ssh keys.

The -k <keyfile> option can be used to copy an authorized_keys file to the /root/.ssh/authorized_keys inside
the container.

Many cloud providers have the notion of user-data scripts.
    - http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
    - http://docs.openstack.org/trunk/openstack-compute/admin/content/user-data.html

There is a cloud-init.start script which is run late in the boot process (so that network is available).
You can provide a file (or script that begins with "#!") with the -u <userdata> option.

