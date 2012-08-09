d:=$(shell mktemp -d)

all:
	@echo -e INITRD=$(INITRD)\\nDIR=$(DIR)
	xz -cd $(INITRD) | (cd $(d) && cpio -id)
	git clone git://github.com/sigaev/linux-initrd $(d)/src
	(cd $(d)/src && git diff origin/upstream...master) | (cd $(d) && git apply)
	rm -fr $(d)/src
	(cd $(d) && find | cpio -oH newc | lzma -9) >$(DIR)/$(notdir $(INITRD))
	rm -fr $(d)
	bash -c 'diff -u <(xz -cd $(INITRD) | cpio -t | sort) <(xz -cd $(DIR)/$(notdir $(INITRD)) | cpio -t | sort)'
