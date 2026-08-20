# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# Linlon VPU firmware for SpacemiT K1 (linlon-v52_v76-80-2)
# 16 codec firmwares: h264dec/hevcdec/h264enc/hevcenc/vp8dec/vp9dec etc.
# Loaded by the kernel VIDEO_LINLON_K1X driver at runtime.

PKG_NAME="k1x-vpu-firmware"
PKG_VERSION="0.0.7"
PKG_ARCH="riscv64"
PKG_LICENSE="CLOSED"
PKG_SITE="https://github.com/spacemit-com/k1x-vpu-firmware"
PKG_URL="https://github.com/spacemit-com/k1x-vpu-firmware/archive/k1-bl-v2.2.11.tar.gz"
PKG_SHA256="effed68eaf0e232b293bded360ed423eca3a37642a6007ca252740301a2f6305"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linlon VPU firmware for SpacemiT K1 hardware video codec"

PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  if [ -d "${PKG_BUILD}/lib/firmware" ]; then
    mkdir -p ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware
    cp -av ${PKG_BUILD}/lib/firmware/* ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/
  fi
}
