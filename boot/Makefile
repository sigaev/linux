mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
DIR:=$(shell mktemp -d)
KERNEL:=$(shell uname -r)
ARCH:=$(if $(findstring x86-64,$(shell file /bin/bash)),x64,x86)
LIB=$(if $(findstring 64,$(ARCH)),lib64,lib)
aws_put=(su sigaev -c "/usr/local/bin/aws put 'x-amz-acl: public-read' 'x-amz-storage-class: REDUCED_REDUNDANCY' sigaev/linux/$(1) $(2)" && wget -S --spider s3.amazonaws.com/sigaev/linux/$(1) 2>&1 | sed -n '/ETag/{s:[^"]*"::;s:":  $(2):;p}' | md5sum -c)

usage:
	@[ -e $(UBUNTU)/.disk ] || (rmdir $(DIR); ! echo -e 'Usage: make boot UBUNTU=<mounted Ubuntu ISO> VERSION=<Boot version: x{86|64}-UU.UU> [NOZFS=1]\nOr:    make modules UBUNTU=<mounted Ubuntu ISO> VBOX=<VirtualBox .deb file> NVIDIA=<NVidia .run file> VERSION=<Modules version: x{86|64}-UU.UU-V.V.VV-NNN.NN-Z.Z.Z.ZZ>' >&2)

boot:
	@echo -e UBUNTU=$(UBUNTU)\\nVERSION=$(VERSION)
	$(MAKE) -C initrd INITRD=$(UBUNTU)/casper/initrd.lz DIR=$(DIR) NOZFS=$(NOZFS)
	mkdir -p $(DIR)/casper $(DIR)/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz $(DIR)
	cp -a grub.cfg $(DIR)/boot/grub
	ln -s /dev/sr1 $(DIR)/casper/filesystem.squashfs
	ln -s /dev/sr2 $(DIR)/modules.sfs
	"$(mkrescue)" -o $(DIR).iso $(DIR)
	$(call aws_put,boot-$(VERSION).iso,$(DIR).iso)
	chmod u+w $(DIR)/.disk
	rm -fr $(DIR)*

modules:
	@echo -e UBUNTU=$(UBUNTU)\\nVBOX=$(VBOX)\\nNVIDIA=$(NVIDIA)\\nVERSION=$(VERSION)
	mkdir $(DIR)/r
	mount -r $(UBUNTU)/casper/filesystem.squashfs $(DIR)/r
	@[ -e $(DIR)/r/lib/modules/$(KERNEL) ] || (umount $(DIR)/r; rmdir $(DIR)/r $(DIR); ! echo Ubuntu live CD mounted at $(UBUNTU) does not match the running kernel >&2)
	mount -toverlayfs -olowerdir=$(DIR)/r,upperdir=$(DIR) overlayfs $(DIR)
	mount -tproc proc $(DIR)/proc
	mount -B /dev $(DIR)/dev
	mount -B /dev/pts $(DIR)/dev/pts
	touch $(DIR)/tmp/nvidia $(DIR)/tmp/vbox
	mount -B "$(NVIDIA)" $(DIR)/tmp/nvidia
	mount -B "$(VBOX)" $(DIR)/tmp/vbox
	cp /etc/resolv.conf $(DIR)/etc
	chroot $(DIR) env MAKEFLAGS=-s sh /tmp/nvidia -a -q --no-runlevel-check -k $(KERNEL)
	chroot $(DIR) dpkg -i /tmp/vbox || chroot $(DIR) apt-get -yf install
	mount -r $(DIR)/usr/share/virtualbox/VBoxGuestAdditions.iso $(DIR)/mnt
	bash -c "\
		mkdir /sys/fs/cgroup/cpu/user/$$$$ || exit 1;\
		echo $$$$ >/sys/fs/cgroup/cpu/user/$$$$/tasks ;\
		echo 1 >/sys/fs/cgroup/cpu/user/$$$$/notify_on_release ;\
		chroot $(DIR) /mnt/VBoxLinuxAdditions.run ;\
		e=$$? ;\
		echo $$$$ >/sys/fs/cgroup/cpu/user/tasks ;\
		xargs -ra/sys/fs/cgroup/cpu/user/$$$$/tasks kill ;\
		exit $$e"
	[ x86 = $(ARCH) ] || chroot $(DIR) apt-add-repository -y ppa:zfs-native/stable
	[ x86 = $(ARCH) ] || chroot $(DIR) apt-get update
	[ x86 = $(ARCH) ] || chroot $(DIR) apt-get -y install ubuntu-zfs
	[ x86 = $(ARCH) ] || cp -a $(DIR)/lib/*gnu/libselinux.so.* $(DIR)
	cp -a $(DIR)/lib/firmware $(DIR)/lib/modules
	[ x64 = $(ARCH) ] || wget -qO- s3.amazonaws.com/sigaev/linux/b43legacy.txz | tar xJC $(DIR)/lib/modules/firmware
	ln -s /cdrom/secret $(DIR)/lib/modules/
	mksquashfs $(DIR)/lib/modules $(DIR)/modules-$(VERSION).sfs -comp xz
	unsquashfs -d $(DIR)/test-sfs $(DIR)/modules-$(VERSION).sfs
	rm $(DIR)/{lib/modules,test-sfs}/{secret,$(KERNEL)/build,firmware/cxgb4/*}
	diff -ru $(DIR)/{lib/modules,test-sfs}
	rm -fr $(DIR)/test-sfs
	umount $(DIR){/mnt,/tmp/{vbox,nvidia},/dev{/pts,},/proc,,/r}
	chmod go+rx $(DIR)
	$(call aws_put,modules-$(VERSION).sfs,$(DIR)/modules-$(VERSION).sfs)
	mkdir -p $(DIR)/1/usr/$(LIB)/opengl/nvidia/lib
	[ ! -e $(DIR)/usr/lib32 ] || mkdir -p $(DIR)/1/usr/lib32/opengl/nvidia/lib
	mv $(DIR)/usr/lib/libGL.so* $(DIR)/1/usr/$(LIB)/opengl/nvidia/lib
	mv $(DIR)/usr/lib/xorg/modules/extensions $(DIR)/1/usr/$(LIB)/opengl/nvidia
	ln -s ../xorg-x11/include $(DIR)/1/usr/$(LIB)/opengl/nvidia
	[ ! -e $(DIR)/usr/lib32 ] || mv $(DIR)/usr/lib32/libGL.so* $(DIR)/1/usr/lib32/opengl/nvidia/lib
	mkdir -p $(DIR)/0/{etc,usr/{bin,$(LIB),share/{doc,man/man1}},var/lib}
	[ ! -e $(DIR)/usr/lib32 ] || mkdir $(DIR)/0/usr/lib32
	mv $(DIR)/etc/OpenCL $(DIR)/0/etc
	mv $(DIR)/usr/bin/nvidia* $(DIR)/0/usr/bin
	rm -fr $(DIR)/usr/lib/{*gnu,VBox*,virtualbox,xorg/modules/drivers/vbox*,dkms,python*}
	mv $(DIR)/usr/lib/* $(DIR)/0/usr/$(LIB)
	[ ! -e $(DIR)/usr/lib32 ] || mv $(DIR)/usr/lib32/* $(DIR)/0/usr/lib32
	mv $(DIR)/usr/share/doc/NVIDIA* $(DIR)/0/usr/share/doc
	mv $(DIR)/usr/share/man/man1/nvidia* $(DIR)/0/usr/share/man/man1
	mv $(DIR)/var/lib/nvidia $(DIR)/0/var/lib
	tar cJf $(DIR)/0.txz -C $(DIR)/0 `ls $(DIR)/0`
	tar cJf $(DIR)/1.txz -C $(DIR)/1 `ls $(DIR)/1`
	mkdir -p $(DIR)/u/{etc,$(LIB),sbin,usr/{sbin,share/{doc,man/man{5,8}}}}
	[ x86 = $(ARCH) ] || mv $(DIR)/etc/hostid $(DIR)/u/etc
	[ x86 = $(ARCH) ] || mv $(DIR)/lib{/{lib*,udev},selinux*} $(DIR)/u/$(LIB)
	[ x86 = $(ARCH) ] || mv $(DIR)/sbin/*z* $(DIR)/u/sbin
	[ x86 = $(ARCH) ] || mv $(DIR)/usr/sbin/spl* $(DIR)/u/usr/sbin
	[ x86 = $(ARCH) ] || mv $(DIR)/usr/share/doc/{lib,u,zfs,spl}* $(DIR)/u/usr/share/doc
	[ x86 = $(ARCH) ] || mv $(DIR)/usr/share/man/man5/vdev* $(DIR)/u/usr/share/man/man5
	[ x86 = $(ARCH) ] || mv $(DIR)/usr/share/man/man8/{vdev,z}* $(DIR)/u/usr/share/man/man8
	[ x86 = $(ARCH) ] || tar cJf $(DIR)/u.txz -C $(DIR)/u `ls $(DIR)/u`
	[ x86 = $(ARCH) ] || tar cJf $(DIR)/$(KERNEL).txz -C $(DIR)/lib/modules $(KERNEL)/updates
	$(call aws_put,nvidia/$(ARCH)/0.txz,$(DIR)/0.txz)
	$(call aws_put,nvidia/$(ARCH)/1.txz,$(DIR)/1.txz)
	[ x86 = $(ARCH) ] || $(call aws_put,zfs/u.txz,$(DIR)/u.txz)
	[ x86 = $(ARCH) ] || $(call aws_put,zfs/$(KERNEL).txz,$(DIR)/$(KERNEL).txz)
	rm -fr $(DIR)
