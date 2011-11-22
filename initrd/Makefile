all:
	@echo INITRD=$(INITRD)
	rm -fr src/*
	xz -cd $(INITRD) | (cd src && cpio -id)
	cd src && git diff upstream...master | git apply
	(cd src && find -name .git -prune -o -print | cpio -oH newc | lzma -9 ) >$(notdir $(INITRD))
	rm -fr src/*
	cd src && git reset --hard
	bash -c 'diff -u <(xz -cd $(INITRD) | cpio -t | sort) <(xz -cd $(notdir $(INITRD)) | cpio -t | sort)'
