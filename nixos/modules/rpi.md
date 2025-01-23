# Raspberry Pi SD card preparation steps

```
~# parted /dev/sdx
(parted) mktable msdos
(parted) mkpart primary fat16 0% 120M
(parted) mkpart primary btrfs 120M 100%
(parted) set 2 boot on
(parted) quit
~# mkfs.vfat -F16 /dev/sdx1
~# mkfs.btrfs /dev/sdx2

~# mount /dev/sdx1 /mnt
~# nix build .#firmware-HOST
~# cp -r result/* /mnt/
~# umount mnt

~# mount /dev/sdx2 /mnt
~# nix copy --to /mnt .#toplevel-HOST
~# nix build --print-out-paths .#toplevel-HOST
~# nix eval .#nixosConfigurations.HOST.config.boot.loader.generic-extlinux-compatible.populateCmd
"/nix/store/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-extlinux-conf-builder.sh -g 20 -t 5"
~# /nix/store/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-extlinux-conf-builder.sh -c  -d ./mnt/boot
~# umount mnt
```
