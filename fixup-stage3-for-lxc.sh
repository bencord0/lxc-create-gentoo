#
# Copyright 2013 Ben Cordero
#
# This file is part of lxc-create-gentoo.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

ln -vs /etc/init.d/sshd etc/runlevels/default/sshd
ln -vs net.lo etc/init.d/net.eth0
ln -vs /etc/init.d/net.eth0 etc/runlevels/boot/net.eth0
rm -vf etc/runlevels/default/netmount
mkdir -vp etc/portage
mkdir -vp usr/portage

patch -E -p1 -u << EOF_PATCH
diff --git a/etc/fstab b/etc/fstab
index 6ff586a..df90c90 100644
--- a/etc/fstab
+++ b/etc/fstab
@@ -1,21 +1,2 @@
-# /etc/fstab: static file system information.
-#
-# noatime turns off atimes for increased performance (atimes normally aren't 
-# needed); notail increases performance of ReiserFS (at the expense of storage 
-# efficiency).  It's safe to drop the noatime options if you want and to 
-# switch between notail / tail freely.
-#
-# The root filesystem should have a pass number of either 0 or 1.
-# All other filesystems should have a pass number of 0 or greater than 1.
-#
-# See the manpage fstab(5) for more information.
-#
-
-# <fs>			<mountpoint>	<type>		<opts>		<dump/pass>
-
-# NOTE: If your BOOT partition is ReiserFS, add the notail option to opts.
-/dev/BOOT		/boot		ext2		noauto,noatime	1 2
-/dev/ROOT		/		ext3		noatime		0 1
-/dev/SWAP		none		swap		sw		0 0
-/dev/cdrom		/mnt/cdrom	auto		noauto,ro	0 0
-/dev/fd0		/mnt/floppy	auto		noauto		0 0
+none	/	none	defaults	0 0
+tmpfs	/dev/shm tmpfs	defaults	0 0
diff --git a/etc/inittab b/etc/inittab
index 2f6af66..6c62fd9 100644
--- a/etc/inittab
+++ b/etc/inittab
@@ -36,12 +36,12 @@ su0:S:wait:/sbin/rc single
 su1:S:wait:/sbin/sulogin
 
 # TERMINALS
-c1:12345:respawn:/sbin/agetty 38400 tty1 linux
-c2:2345:respawn:/sbin/agetty 38400 tty2 linux
-c3:2345:respawn:/sbin/agetty 38400 tty3 linux
-c4:2345:respawn:/sbin/agetty 38400 tty4 linux
-c5:2345:respawn:/sbin/agetty 38400 tty5 linux
-c6:2345:respawn:/sbin/agetty 38400 tty6 linux
+#c1:12345:respawn:/sbin/agetty 38400 tty1 linux
+#c2:2345:respawn:/sbin/agetty 38400 tty2 linux
+#c3:2345:respawn:/sbin/agetty 38400 tty3 linux
+#c4:2345:respawn:/sbin/agetty 38400 tty4 linux
+#c5:2345:respawn:/sbin/agetty 38400 tty5 linux
+#c6:2345:respawn:/sbin/agetty 38400 tty6 linux
 
 # SERIAL CONSOLES
 #s0:12345:respawn:/sbin/agetty 115200 ttyS0 vt100
@@ -57,3 +57,4 @@ ca:12345:ctrlaltdel:/sbin/shutdown -r now
 # to the "default" runlevel.
 x:a:once:/etc/X11/startDM.sh
 
+1:12345:respawn:/sbin/agetty -a root --noclear 115200 console linux
diff --git a/etc/issue b/etc/issue
index 015e46d..e69de29 100644
--- a/etc/issue
+++ b/etc/issue
@@ -1,3 +0,0 @@
-
-This is \n.\O (\s \m \r) \t
-
diff --git a/etc/rc.conf b/etc/rc.conf
index 4c186dc..688c4c1 100644
--- a/etc/rc.conf
+++ b/etc/rc.conf
@@ -147,7 +147,7 @@ unicode="YES"
 #
 # This should be set to the value representing the environment this file is
 # PRESENTLY in, not the virtualization the environment is capable of.
-#rc_sys=""
+rc_sys="lxc"
 
 # This is the number of tty's used in most of the rc-scripts (like
 # consolefont, numlock, etc ...)
diff --git a/etc/shadow b/etc/shadow
index ca9c9c1..df832db 100644
--- a/etc/shadow
+++ b/etc/shadow
@@ -1,4 +1,4 @@
-root:*:10770:0:::::
+root::10770:0:::::
 halt:*:9797:0:::::
 operator:*:9797:0:::::
 shutdown:*:9797:0:::::
EOF_PATCH

cp -v $(dirname "${BASH_SOURCE[0]}")/cloud-init.start etc/local.d/
