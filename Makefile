INITRD=$(UBUNTU)/casper/initrd.lz
LOCAL_INITRD=initrd/$(notdir $(INITRD))-$(ARCH)
ISO=boot-$(ARCH).iso

mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
i=iso-$(ARCH)

all: echo $(LOCAL_INITRD)
	mkdir -p $(i)/casper $(i)/boot/grub
	cp -a $(UBUNTU)/.disk $(UBUNTU)/casper/vmlinuz $(i)
	ln $(LOCAL_INITRD) $(i)/$(notdir $(INITRD))
	ln grub.cfg $(i)/boot/grub
	ln -s /dev/sr1 $(i)/casper/filesystem.squashfs
	ln -s /dev/sr2 $(i)/modules.sfs
	"$(mkrescue)" -o $(ISO) $(i)
	chmod u+w $(i)/.disk
	rm -fr $(i) $(LOCAL_INITRD)

echo:
	@cat README
	@echo -e \\nARCH=$(ARCH)\\nUBUNTU=$(UBUNTU)

$(LOCAL_INITRD):
	$(MAKE) -C initrd INITRD=$(INITRD)
