# Makefile for building archiso

all: lint clean depends profile scripts packages permissions iso

lint:
	shellcheck -s bash $(wildcard ./*.sh) \
			$(wildcard scripts/*.sh)

clean:
	sudo ./clean.sh

clobber:
	sudo ./clobber.sh

depends:
	./check_dependencies.sh

profile:
	./copy_profile.sh

scripts:
	./add_scripts.sh

packages:
	./add_packages.sh

permissions:
	./edit_profile_permissions.sh

iso:
	./make_iso.sh

test:
	./test_iso.sh
