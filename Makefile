
DOCKER := $(shell { command -v podman || command -v docker; })
TIMESTAMP := $(shell TZ='Europe/Warsaw' date +"%Y%m%d%H%M")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null)
detected_OS := $(shell uname)  # Classify UNIX OS

ifeq ($(strip $(detected_OS)),Darwin) #We only care if it's OS X
SELINUX1 :=
SELINUX2 :=
else
SELINUX1 := :z
SELINUX2 := ,z
endif

.PHONY: all left clean_firmware clean_image clean

all:
	$(shell bin/get_version.sh >> /dev/null)
	"$(DOCKER)" build --tag zmk --file Dockerfile .
	"$(DOCKER)" run --rm -it --name zmk \
		-v "/mnt/d/messing around with zmk/adv360-pro-zmk/firmware:/app/firmware$(SELINUX1)" \
		-v "/mnt/d/messing around with zmk/adv360-pro-zmk/config:/app/config:ro$(SELINUX2)" \
		-e TIMESTAMP=$(TIMESTAMP) \
		-e COMMIT=$(COMMIT) \
		-e BUILD_RIGHT=true \
		zmk
	$(shell git checkout config/version.dtsi)

left:
	$(shell bin/get_version.sh >> /dev/null)
	$(DOCKER) build --tag zmk --file Dockerfile .
	$(DOCKER) run --rm -it --name zmk \
		-v $(PWD)/firmware:/app/firmware$(SELINUX1) \
		-v $(PWD)/config:/app/config:ro$(SELINUX2) \
		-e TIMESTAMP=$(TIMESTAMP) \
		-e COMMIT=$(COMMIT) \
		-e BUILD_RIGHT=false \
		zmk
	$(shell git checkout config/version.dtsi)

clean_firmware:
	rm -f firmware/*.uf2

clean_image:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable

clean: clean_firmware clean_image
