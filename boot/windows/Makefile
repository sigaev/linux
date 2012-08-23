mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
iso:=$(shell mktemp -d)

all:
	mkdir -p $(iso)/boot/grub
	cp -a grub.cfg $(iso)/boot/grub
	"$(mkrescue)" -o $(iso).iso $(iso)
	aws put 'x-amz-acl: public-read' 'x-amz-storage-class: REDUCED_REDUNDANCY' sigaev/linux/boot-hd0,3.iso $(iso).iso
	rm -fr $(iso)*
