# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# IMG PowerVR userspace runtime + firmware for K1 (BXE-2-32, BVNC 36.29.52.182)
# Prebuilt binaries from SpacemiT. Provides libpvr_dri_support.so (dlopen'ed by
# the mesa pvr gallium frontend) and the GPU firmware rgx.fw.36.29.52.182.
# GLES/EGL/Vulkan libraries are provided by the mesa package instead.

PKG_NAME="img-gpu-powervr"
PKG_VERSION="k1-bl-v2.2.9"
PKG_ARCH="riscv64"
PKG_LICENSE="CLOSED"
PKG_SITE="https://github.com/spacemit-com/img-gpu-powervr"
PKG_URL="https://github.com/spacemit-com/img-gpu-powervr/archive/k1-bl-v2.2.y.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="IMG PowerVR GPU userspace runtime and firmware for SpacemiT K1"

# prebuilt binaries, nothing to compile
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+speed"

make_target() {
  :
}

makeinstall_target() {
  # GPU firmware (loaded by the kernel img-rogue driver) - installed into the
  # kernel-overlays base firmware dir so that scripts/image can symlink
  # /usr/lib/firmware -> /run/kernel-overlays/firmware (runtime overlay mount)
  if [ -d "${PKG_BUILD}/target/lib/firmware" ]; then
    mkdir -p ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware
    cp -av ${PKG_BUILD}/target/lib/firmware/* ${INSTALL}/usr/lib/kernel-overlays/base/lib/firmware/
  fi

  # PVR runtime libraries (libpvr_dri_support.so, libsrv_um.so, ...)
  # NOTE: GLES/EGL/Vulkan libs from img are installed too - the vendor layout
  # provides libGLESv2.so -> libGLESv2_PVR_MESA.so (PVR native GLES) alongside
  # mesa's versioned libGLESv2.so.2 (which Kodi links against via DT_NEEDED).
  # libEGL.so* is NOT provided by img (mesa provides it).
  if [ -d "${PKG_BUILD}/target/usr/lib" ]; then
    mkdir -p ${INSTALL}/usr/lib
    for lib in ${PKG_BUILD}/target/usr/lib/lib*.so*; do
      [ -f "$lib" ] || continue
      libname=$(basename "$lib")
      case "$libname" in
        libEGL*|libGL.so*)
          # mesa provides libEGL/libGL; skip img's copies
          continue
          ;;
      esac
      cp -av "$lib" ${INSTALL}/usr/lib/
    done
    if [ -d "${PKG_BUILD}/target/usr/lib/riscv64-linux-gnu" ]; then
      cp -av ${PKG_BUILD}/target/usr/lib/riscv64-linux-gnu/* ${INSTALL}/usr/lib/
    fi
  fi

  # /usr/local payload (pvr tools, shaders) - matches the vendor RPATH layout
  if [ -d "${PKG_BUILD}/target/usr/local" ]; then
    mkdir -p ${INSTALL}/usr/local
    cp -av ${PKG_BUILD}/target/usr/local/* ${INSTALL}/usr/local/
  fi

  # pvr config files (powervr.ini, vulkan/OpenCL icd)
  if [ -d "${PKG_BUILD}/target/etc" ]; then
    cp -av ${PKG_BUILD}/target/etc ${INSTALL}/etc/
  fi
}

post_install() {
  # unblank the pwm-backlight at boot (see system.d/backlight-enable.service)
  enable_service backlight-enable.service
}
