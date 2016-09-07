mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
DIR:=$(shell mktemp -d)
KERNEL:=$(shell uname -r)
ARCH:=$(if $(findstring x86-64,$(shell file /bin/bash)),x64,x86)
LIB=$(if $(findstring 64,$(ARCH)),lib64,lib)
aws_put=(su sigaev -c "/usr/local/bin/aws put 'x-amz-acl: public-read' 'x-amz-storage-class: REDUCED_REDUNDANCY' sigaev/linux/$(1) $(2)" && wget -S --spider s3.amazonaws.com/sigaev/linux/$(1) 2>&1 | sed -n '/ETag/{s:[^"]*"::;s:":  $(2):;p}' | md5sum -c)

usage:
	@[ -e $(UBUNTU)/.disk ] || (rmdir $(DIR); ! echo -e 'Usage: make boot UBUNTU=<mounted Ubuntu ISO> VERSION=<Boot version: x{86|64}-UU.UU[.U]>\nOr:    make modules UBUNTU=<mounted Ubuntu ISO> NVIDIA=<NVidia .run file> VERSION=<Modules version: x{86|64}-UU.UU[.U]-NNN.NN>' >&2)

boot:
	@echo -e UBUNTU=$(UBUNTU)\\nVERSION=$(VERSION)
	$(MAKE) -C initrd INITRD=$(UBUNTU)/casper/initrd.lz DIR=$(DIR) NOZFS=1
	mkdir -p $(DIR)/casper $(DIR)/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz.efi $(DIR)
	cp -a grub.cfg $(DIR)/boot/grub
	ln -s /dev/sr1 $(DIR)/casper/filesystem.squashfs
	ln -s /dev/sr2 $(DIR)/modules.sfs
	"$(mkrescue)" -o $(DIR).iso $(DIR)
	$(call aws_put,boot-$(VERSION).iso,$(DIR).iso)
	chmod u+w $(DIR)/.disk
	rm -fr $(DIR)*

modules:
	@echo -e UBUNTU=$(UBUNTU)\\nNVIDIA=$(NVIDIA)\\nVERSION=$(VERSION)
	mkdir $(DIR)/r
	mkdir -p /tmp/xxx
	mount -r $(UBUNTU)/casper/filesystem.squashfs $(DIR)/r
	@[ -e $(DIR)/r/lib/modules/$(KERNEL) ] || (umount $(DIR)/r; rmdir $(DIR)/r $(DIR); ! echo Ubuntu live CD mounted at $(UBUNTU) does not match the running kernel >&2)
	mount -toverlay -olowerdir=$(DIR)/r,upperdir=$(DIR),workdir=/tmp/xxx overlay $(DIR)
	mount -tproc proc $(DIR)/proc
	mount -B /dev $(DIR)/dev
	mount -B /dev/pts $(DIR)/dev/pts
	mount -B /sys $(DIR)/sys
	touch $(DIR)/tmp/nvidia
	mount -B "$(NVIDIA)" $(DIR)/tmp/nvidia
	cp /etc/resolv.conf $(DIR)/etc
	chroot $(DIR) env MAKEFLAGS=-s sh /tmp/nvidia -a -q --no-runlevel-check -k $(KERNEL) --{opengl,utility}-libdir=lib
	cp -a $(DIR)/lib/firmware $(DIR)/lib/modules
	mksquashfs $(DIR)/lib/modules $(DIR)/modules-$(VERSION).sfs -comp xz
	unsquashfs -d $(DIR)/test-sfs $(DIR)/modules-$(VERSION).sfs
	rm $(DIR)/{lib/modules,test-sfs}/$(KERNEL)/build
	diff -ru $(DIR)/{lib/modules,test-sfs}
	rm -fr $(DIR)/test-sfs
	umount $(DIR){/tmp/nvidia,/sys,/dev{/pts,},/proc,,/r}
	mv $(DIR)/usr/lib/{*gnu/*,}
	chmod go+rx $(DIR)
	$(call aws_put,modules-$(VERSION).sfs,$(DIR)/modules-$(VERSION).sfs)
	rm -fr $(DIR)/{etc/{ld.so.cache,resolv.conf},lib,modules*,r*,tmp,usr/lib/*gnu,var/cache}
	tar cJf $(DIR)/all.txz -C $(DIR) `ls $(DIR)`
	$(call aws_put,nvidia/$(ARCH)/all.txz,$(DIR)/all.txz)
	rm -fr $(DIR)
