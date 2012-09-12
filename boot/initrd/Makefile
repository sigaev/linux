d:=$(shell mktemp -d)

all:
	@echo -e INITRD=$(INITRD)\\nDIR=$(DIR)\\nNOZFS=$(NOZFS)
	xz -cd $(INITRD) | (cd $(d) && cpio -id)
	git clone git://github.com/sigaev/linux-initrd $(d)/src
	(cd $(d)/src && git diff origin/upstream...master) | patch -fd$(d) -p1
	rm -fr $(d)/src
	[ "$(NOZFS)" ] || file $(d)/lib/modules/*/kernel/fs/squashfs/squashfs.ko | grep -q 32-bit || wget -qO- "s3.amazonaws.com/sigaev/linux/zfs/`ls $(d)/lib/modules`.txz" | tar xJC $(d)/lib/modules
	/sbin/depmod -b $(d) "`ls $(d)/lib/modules`"
	(cd $(d) && find | cpio -oH newc | lzma -9) >$(DIR)/$(notdir $(INITRD))
	rm -fr $(d)
