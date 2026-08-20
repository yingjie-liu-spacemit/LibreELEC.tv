# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# SpacemiT K1 vendor OpenSBI (k1-bl-v2.2.y) - fw_dynamic.itb for the SPL boot chain

PKG_NAME="opensbi"
PKG_VERSION="1.3"
PKG_ARCH="riscv64"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/spacemit-com/opensbi"
PKG_URL="https://github.com/spacemit-com/opensbi/archive/k1-bl-v2.2.y.tar.gz"
PKG_DEPENDS_TARGET="toolchain u-boot-tools:host dtc:host"
PKG_LONGDESC="SpacemiT K1 vendor OpenSBI (fw_dynamic.itb)"

make_target() {
  make CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" \
       PLATFORM=generic PLATFORM_DEFCONFIG=k1_defconfig \
       FW_PIC=y -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  BUILD_DIR="${PKG_BUILD}/build/platform/generic/firmware"
  for f in fw_dynamic.bin fw_dynamic.elf fw_dynamic.itb fw_jump.bin fw_payload.bin; do
    if [ -f "${BUILD_DIR}/${f}" ]; then
      cp -av ${BUILD_DIR}/${f} ${INSTALL}/usr/share/bootloader
    fi
  done
}
