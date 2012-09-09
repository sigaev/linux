mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
DIR:=$(shell mktemp -d)

all: echo
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

echo:
	@[ -e $(UBUNTU)/.disk ] || (rmdir $(DIR); ! echo 'Usage: make UBUNTU=<mounted Ubuntu ISO> VERSION=<Ubuntu version: x{86|64}-XX.XX>' >&2)
	@cat README
	@echo -e \\nUBUNTU=$(UBUNTU)\\nVERSION=$(VERSION)

modules:
	mkdir $(DIR)/r
	mount -r filesystem.squashfs $(DIR)/r
	mount -toverlayfs -olowerdir=$(DIR)/r,upperdir=$(DIR) overlayfs $(DIR)
	mount -tproc proc $(DIR)/proc
	mount -B /dev $(DIR)/dev
	mount -B /dev/pts $(DIR)/dev/pts
	mount -B /dev/shm $(DIR)/dev/shm
	touch $(DIR)/tmp/nvidia $(DIR)/tmp/vbox
	mount -B nvidia $(DIR)/tmp/nvidia
	mount -B vbox $(DIR)/tmp/vbox
	cp /etc/resolv.conf $(DIR)/etc
	chroot $(DIR) env MAKEFLAGS=-s sh /tmp/nvidia -a -q --no-runlevel-check
	chroot $(DIR) dpkg -i /tmp/vbox
	mount -r $(DIR)/usr/share/virtualbox/VBoxGuestAdditions.iso $(DIR)/mnt
	chroot $(DIR) /mnt/VBoxLinuxAdditions.run
	umount $(DIR)/mnt $(DIR)/tmp/vbox $(DIR)/tmp/nvidia $(DIR)/dev/shm $(DIR)/dev/pts $(DIR)/dev $(DIR)/proc $(DIR) $(DIR)/r
	rm -fr $(DIR)
