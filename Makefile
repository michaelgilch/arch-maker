# Makefile for building archiso

all: clean depends profile installer-scripts installer-packages permissions iso

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

installer-scripts:
	./add_installer_scripts.sh

installer-packages:
	./add_installer_packages.sh

permissions:
	./edit_profile_permissions.sh

iso:
	./make_iso.sh

test:
	./test_iso.sh
