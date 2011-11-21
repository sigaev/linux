all:
	@echo INITRD=$(INITRD)
	rm -fr ../../*
	xz -cd "$(INITRD)" | (cd ../.. && cpio -id)
	cd ../.. && (git diff upstream...master | git apply)
	cd ../.. && (find -name .git -prune -o -print | cpio -oH newc | lzma -7 >.git/scripts/`basename "$(INITRD)"`)
	rm -fr ../../*
	cd ../.. && git reset --hard
	bash -c 'diff -u <(xz -cd "$(INITRD)" | cpio -t | sort) <(xz -cd `basename "$(INITRD)"` | cpio -t | sort)'
