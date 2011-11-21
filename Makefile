all:
	@echo INITRD=$(INITRD)
	rm -fr ../../*
	xz -cd "$(INITRD)" | (cd ../.. && cpio -id)
	cd ../.. && (git diff upstream...master | git apply)
	cd ../.. && (find * | cpio -o | xz -9 >.git/scripts/`basename "$(INITRD)"`)
	rm -fr ../../*
	cd ../.. && git reset --hard
	bash -c 'diff -u <(xz -cd "$(INITRD)" | cpio -t | sort) <(xz -cd `basename "$(INITRD)"` | cpio -t | sort); true'
