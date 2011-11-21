INITRD=$(UBUNTU)/casper/initrd.lz
LOCAL_INITRD=initrd/$(notdir $(INITRD))

all: echo $(LOCAL_INITRD)

echo:
	@echo UBUNTU=$(UBUNTU)

$(LOCAL_INITRD):
	make -C initrd INITRD=$(INITRD)
