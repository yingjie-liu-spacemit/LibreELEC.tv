# Spacemit

This project is for SpacemiT K1 SoC devices (RISC-V).

The K1 port uses the vendor BSP components (kernel, U-Boot, OpenSBI, VPU
firmware, MPP, PowerVR GPU driver) released together as `k1-bl-v2.2.x`.
These components are tightly coupled and are pinned to exact commits; see the
version pinning note in `options`.

## Devices

**K1**
* Milk-V Jupiter
* SpacemiT MUSE Book
* SpacemiT MUSE Card
* SpacemiT MUSE Pi / MUSE Pi Pro
* SpacemiT MUSE N1

All of them use the shared configuration in [devices/k1](devices/k1). The `k1`
U-Boot build selects the device tree at boot from the `product_name` value in
the board EEPROM, so there is a single image for every board rather than one
image per board.

Tested on Milk-V Jupiter and SpacemiT MUSE Book. The vendor kernel ships 28
K1 board device trees (`k1-x_*.dts`, `m1-x_*.dts`), including InnoBoard-Pi,
LX-V10, MINI-PC, MUSE Paper and LPi3A; boards beyond the ones listed above are
expected to work the same way, but have not been verified.

## Build

```
PROJECT=Spacemit DEVICE=k1 ARCH=riscv64 make image
```

The result is
`target/LibreELEC-k1.riscv64-13.0-devel-<timestamp>-<commit>.img.gz`.

## Installation

The image is a complete SD card image with a GPT layout: the K1 boot chain
(bootinfo / FSBL / U-Boot env / OpenSBI / U-Boot) lives in the first 4 MiB at
fixed offsets, followed by the `bootfs` (ext4, 512 MiB) and `rootfs` (ext4)
partitions. Write it to the card as a whole, not to a partition:

```
gunzip -c LibreELEC-k1.riscv64-*.img.gz | dd of=/dev/sdX bs=4M conv=fsync
```

The rootfs partition is grown to the card size on first boot, which reboots the
system once.

### Reflash required when coming from a 256 MiB bootfs

`bootfs` used to be 256 MiB. It holds the kernel `Image`, the squashfs
`SYSTEM` and the device trees. An update rewrites the kernel and `SYSTEM` in
full and is refused unless at least 5 MiB stays free on `bootfs` afterwards,
which no longer fits in 256 MiB: in testing a first update left only about
1 MiB free, so every further update stopped at `Checking size: FAILED` and the
system rebooted without updating anything.

Current images use a 512 MiB `bootfs` (the `rootfs` partition therefore starts
at 516 MiB instead of 260 MiB). **A card written with the old 256 MiB layout
must be written from scratch once**: it cannot be brought to the new layout
through `/storage/.update`, because the partition table and the `bootfs` size
are fixed when the image is written.

Updates from `/storage/.update` work normally after that.

## Notes and limitations

* **SD card only.** Writing this image to the eMMC of a Milk-V Jupiter does not
  boot: the board falls back to the U-Boot in its SPI flash, which looks for
  the kernel on partition 2 (the Bianbu layout), and that U-Boot also fails
  multi-block eMMC reads on this module. Reported for the Milk-V Jupiter; not
  verified on other K1 boards.
* **HDMI EDID.** The HDMI driver was reported to fail reading the EDID on the
  Milk-V Jupiter used for testing (`hdmi_i2c_write wait hdmi ddc command done
  timeout`), so Kodi only offers the default modes. Not addressed.
* **MIPI camera is disabled.** The vendor camera stack (CCIC/ISP/CPP/sensor)
  was reported to hang the board in about one boot in five, in the camera clock
  sequence triggered by udev's `v4l_id`, although no camera was attached. It is
  disabled in the kernel configuration; USB webcams (`USB_VIDEO_CLASS`) and the
  VPU are unaffected.
* **Version skew.** The kernel is `k1-bl-v2.2.10-release` while
  `k1x-vpu-firmware`, `mpp` and `esos-firmware` come from
  `k1-bl-v2.2.11-release`. This combination is tested and works, but the
  releases are meant to be used together.
* **HDMI audio needs the RCPU.** The HDMI audio (SSPA) block only works once
  the RCPU remoteproc has booted `esos.elf`, which provides the `adma-service`
  DMA channel. A modprobe `install` rule waits up to 10 s for it and skips
  `spacemit-hdmiaudio` if it never appears: no HDMI audio rather than a hung
  board.

## Links

* https://www.spacemit.com
* https://github.com/spacemit-com
* Kernel device trees: `arch/riscv/boot/dts/spacemit/k1-x_*.dts` in the
  Spacemit vendor kernel
