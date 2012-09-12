mkrescue:=$(shell which grub2-mkrescue || which grub-mkrescue)
iso:=$(shell mktemp -d)
aws_put=(su sigaev -c "/usr/local/bin/aws put 'x-amz-acl: public-read' 'x-amz-storage-class: REDUCED_REDUNDANCY' sigaev/linux/$(1) $(2)" && wget -S --spider s3.amazonaws.com/sigaev/linux/$(1) 2>&1 | sed -n '/ETag/{s:[^"]*"::;s:":  $(2):;p}' | md5sum -c)

all:
	mkdir -p $(iso)/boot/grub
	cp -a grub.cfg $(iso)/boot/grub
	"$(mkrescue)" -o $(iso).iso $(iso)
	$(call aws_put,boot-hd0-3.iso,$(iso).iso)
	rm -fr $(iso)*
