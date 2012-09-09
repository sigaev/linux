mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
DIR:=$(shell mktemp -d)

usage:
	@[ -e $(UBUNTU)/.disk ] || (rmdir $(DIR); ! echo -e 'Usage: make boot UBUNTU=<mounted Ubuntu ISO> VERSION=<Boot version: x{86|64}-UU.UU>\nOr:    make modules UBUNTU=<mounted Ubuntu ISO> VBOX=<VirtualBox .deb file> NVIDIA=<NVidia .run file> VERSION=<Modules version: x{86|64}-UU.UU-V.V.VV-NNN.NN-Z.Z.Z.ZZrcZZ>' >&2)

boot:
	@echo -e UBUNTU=$(UBUNTU)\\nVERSION=$(VERSION)
	$(MAKE) -C initrd INITRD=$(UBUNTU)/casper/initrd.lz DIR=$(DIR)
	mkdir -p $(DIR)/casper $(DIR)/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz $(DIR)
	cp -a grub.cfg $(DIR)/boot/grub
	ln -s /dev/sr1 $(DIR)/casper/filesystem.squashfs
	ln -s /dev/sr2 $(DIR)/modules.sfs
	"$(mkrescue)" -o $(DIR).iso $(DIR)
	aws put 'x-amz-acl: public-read' 'x-amz-storage-class: REDUCED_REDUNDANCY' sigaev/linux/boot-$(VERSION).iso $(DIR).iso
	chmod u+w $(DIR)/.disk
	rm -fr $(DIR)*

modules:
	@echo -e UBUNTU=$(UBUNTU)\\nVBOX=$(VBOX)\\nNVIDIA=$(NVIDIA)\\nVERSION=$(VERSION)
	mkdir $(DIR)/r
	mount -r $(UBUNTU)/casper/filesystem.squashfs $(DIR)/r
	#TODO: check that the running kernel matches $(DIR)/r/lib/modules
	mount -toverlayfs -olowerdir=$(DIR)/r,upperdir=$(DIR) overlayfs $(DIR)
	mount -tproc proc $(DIR)/proc
	mount -B /dev $(DIR)/dev
	mount -B /dev/pts $(DIR)/dev/pts
	touch $(DIR)/tmp/nvidia $(DIR)/tmp/vbox
	mount -B "$(NVIDIA)" $(DIR)/tmp/nvidia
	mount -B "$(VBOX)" $(DIR)/tmp/vbox
	cp /etc/resolv.conf $(DIR)/etc
	chroot $(DIR) env MAKEFLAGS=-s sh /tmp/nvidia -a -q --no-runlevel-check -k `ls $(DIR)/lib/modules | head -1`
	chroot $(DIR) dpkg -i /tmp/vbox || chroot $(DIR) apt-get -yf install
	mount -r $(DIR)/usr/share/virtualbox/VBoxGuestAdditions.iso $(DIR)/mnt
	mkdir /sys/fs/cgroup/cpu/vbox
	bash -c "echo $$$$ >/sys/fs/cgroup/cpu/vbox/tasks; exec chroot $(DIR) /mnt/VBoxLinuxAdditions.run"
	xargs -ra/sys/fs/cgroup/cpu/vbox/tasks kill
	#TODO: install ZFS
	cp -a $(DIR)/lib/firmware $(DIR)/lib/modules
	ln -s /cdrom/secret $(DIR)/lib/modules/
	mksquashfs $(DIR)/lib/modules /tmp/modules-$(VERSION).sfs -comp xz
	rmdir /sys/fs/cgroup/cpu/vbox
	umount $(DIR)/mnt $(DIR)/tmp/vbox $(DIR)/tmp/nvidia $(DIR)/dev/pts $(DIR)/dev $(DIR)/proc $(DIR) $(DIR)/r
	#TODO: upload the userspace
	rm -fr $(DIR)
