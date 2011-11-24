INITRD=$(UBUNTU)/casper/initrd.lz
LOCAL_INITRD=initrd/$(notdir $(INITRD))
ISO=boot.iso

mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)

all: echo $(LOCAL_INITRD)
	mkdir -p iso/casper iso/boot/grub
	cp -a grub.cfg iso/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz $(LOCAL_INITRD) iso
	ln -sfn /dev/sr1 iso/casper/filesystem.squashfs
	ln -sfn /dev/sr2 iso/modules.sfs
	"$(mkrescue)" -o $(ISO) iso
	chmod u+w iso/.disk
	rm -fr iso $(LOCAL_INITRD)

echo:
	@cat README
	@echo -e \\nUBUNTU=$(UBUNTU)

$(LOCAL_INITRD):
	$(MAKE) -C initrd INITRD=$(INITRD)
