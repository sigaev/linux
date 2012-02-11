INITRD=$(UBUNTU)/casper/initrd.lz
ISO=boot-$(ARCH).iso

mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
DIR:=$(shell mktemp -d)

all: echo local-initrd
	mkdir -p $(DIR)/casper $(DIR)/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz $(DIR)
	cp -a grub.cfg $(DIR)/boot/grub
	ln -s /dev/sr1 $(DIR)/casper/filesystem.squashfs
	ln -s /dev/sr2 $(DIR)/modules.sfs
	"$(mkrescue)" -o $(ISO) $(DIR)
	chmod u+w $(DIR)/.disk
	rm -fr $(DIR)

echo:
	@cat README
	@echo -e \\nARCH=$(ARCH)\\nUBUNTU=$(UBUNTU)

local-initrd:
	$(MAKE) -C initrd INITRD=$(INITRD) DIR=$(DIR)
