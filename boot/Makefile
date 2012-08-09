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
