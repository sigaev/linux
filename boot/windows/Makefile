ISO=boot-hd0,3.iso

mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
iso:=$(shell mktemp -d)

all:
	mkdir -p $(iso)/boot/grub
	cp -a grub.cfg $(iso)/boot/grub
	"$(mkrescue)" -o $(ISO) $(iso)
	rm -fr $(iso)
