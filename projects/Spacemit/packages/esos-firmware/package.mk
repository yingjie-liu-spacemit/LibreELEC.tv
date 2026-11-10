# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# Firmware for the SpacemiT K1 audio co-processor (RCPU, "esos").
# The k1x-rproc remoteproc driver loads it and, in doing so, powers up the
# audio subsystem. Without it, the HDMI audio (SSPA) driver hangs the bus on
# reset deassert, stalling the boot.
#
# The license forbids shipping it as part of the Linux kernel, so it is
# installed as a regular file and the drivers involved are built as modules.

PKG_NAME="esos-firmware"
PKG_VERSION="k1-bl-v2.2.11-release"
PKG_ARCH="riscv64"
PKG_LICENSE="LicenseRef-nonfree"
PKG_SITE="https://github.com/spacemit-com/buildroot-ext"
# Coupled to the other K1 vendor packages: see "Version pinning" in
# projects/Spacemit/options before changing the version.
PKG_URL="https://raw.githubusercontent.com/spacemit-com/buildroot-ext/${PKG_VERSION}/board/spacemit/k1/target_overlay/lib/firmware/esos.elf"
PKG_SHA256="a7ef0129310a0fdc71d848490b4d6fdd73fbecc31d9f6b314662617dfdaaaefc"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="SpacemiT K1 audio co-processor (esos) firmware"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  cp ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} ${PKG_BUILD}/esos.elf
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware
    cp -av ${PKG_BUILD}/esos.elf ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/

  mkdir -p ${INSTALL}/usr/lib/modprobe.d
    cp -av ${PKG_DIR}/modprobe.d/*.conf ${INSTALL}/usr/lib/modprobe.d/
}
