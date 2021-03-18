# Arch-Maker

Arch-Maker is my custom Arch Linux installer built using [ArchIso](https://wiki.archlinux.org/index.php/archiso).
While the installation scripts have been written to perform common tasks that I perform on my installs, I have tried to make it open enough to work for others as well.

## Building an ISO

Simply running `make` will perform an entire build of a custom ISO, including dependency checking, adding packages and scripts, and generating a .iso in bin/.

The Makefile has each step in the build process broken down for troubleshooting purposes.

- **`lint`** uses shellcheck to lint both the build scripts as well as any shell scripts placed in scripts/.
- **`clean`** removes all build artifacts in `build/`.
- **`clobber`** removes both build artifacts in `build/` as well as ISOs in `bin/`.
- **`depends`** checks for dependencies of the build process and testing process.
- **`profile`** creates a copy of the releng profile for customization.
- **`files`** copies all files in `scripts/` to the ISOs `root/`.
- **`packages`** installs additional packages to the ISO.
- **`permissions`** makes sure the install scripts will all be executable once on the ISO. **NOTE:** As of 2021-03-18, this currently requires a custom build of mkarchiso (part of archiso package). A merge request has been submitted for issue #100 at [gitlab - archiso](https://gitlab.archlinux.org/archlinux/archiso).
- **`iso`** builds the ISO to `bin/`.
- **`test`** launches the ISO using qemu virtualization.

## Running an Install

