INITRD=$(UBUNTU)/casper/initrd.lz
LOCAL_INITRD=initrd/$(notdir $(INITRD))
ISO=boot.iso

$(ISO): echo $(LOCAL_INITRD)
	mkdir -p iso/casper iso/boot/grub
	cp -a grub.cfg iso/boot/grub
	cp -a $(UBUNTU)/.disk iso
	cp -a $(UBUNTU)/casper/vmlinuz iso
	cp -a $(LOCAL_INITRD) iso
	ln -sfn /dev/sr1 iso/casper/filesystem.squashfs
	ln -sfn /dev/sr2 iso/modules.sfs
	grub-mkrescue -o $(ISO) iso
	rm -fr iso

echo:
	@echo UBUNTU=$(UBUNTU)

$(LOCAL_INITRD):
	make -C initrd INITRD=$(INITRD)
