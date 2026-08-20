# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# SpacemiT K1 vendor U-Boot 2022.10 (k1-bl-v2.2.y)
# Builds the complete boot chain: FSBL.bin (SPL + AIHD header), bootinfo_*.bin,
# u-boot.itb (multi-dtb FIT), u-boot-env-default.bin

PKG_NAME="u-boot"
PKG_VERSION="2022.10"
PKG_ARCH="riscv64"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/spacemit-com/uboot-2022.10"
PKG_URL="https://github.com/spacemit-com/uboot-2022.10/archive/k1-bl-v2.2.y.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl:host pkg-config:host Python3:host swig:host pyelftools:host opensbi"
PKG_LONGDESC="SpacemiT K1 vendor U-Boot (SPL/FSBL + OpenSBI payload + FIT u-boot.itb)"
PKG_BUILD_FLAGS="+speed"

PKG_STAMP="${UBOOT_SYSTEM} ${UBOOT_TARGET}"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader"

make_target() {
  setup_pkg_config_host
  if [ -z "${UBOOT_SYSTEM}" ]; then
    echo "UBOOT_SYSTEM must be set to build an image"
    exit 1
  fi
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=riscv make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=riscv make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" ${UBOOT_TARGET:-k1_defconfig}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=riscv make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" HOSTSTRIP="true"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  for f in FSBL.bin bootinfo_sd.bin bootinfo_emmc.bin bootinfo_spinor.bin bootinfo_spinand.bin \
           u-boot.itb u-boot-env-default.bin u-boot-nodtb.bin u-boot.dtb; do
    if [ -f "${PKG_BUILD}/${f}" ]; then
      cp -av ${PKG_BUILD}/${f} ${INSTALL}/usr/share/bootloader
    fi
  done
  # custom env overlay used by vendor u-boot from bootfs (env_k1-x.txt)
  if find_file_path bootloader/env_k1-x.txt; then
    cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
  fi
}
