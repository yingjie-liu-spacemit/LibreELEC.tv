# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# SpacemiT MPP (Media Process Platform) - userspace video codec library
# Provides libspacemit_mpp.so + libv4l2_linlonv5v7_codec.so
# Used by ffmpeg's --enable-stcodec for hardware-accelerated video decode/encode
# via the kernel VIDEO_LINLON_K1X V4L2 mem2mem driver.
#
# K1 uses the al/vcodec/v4l2/linlonv5v7 path (pure V4L2, no verisilicon/omx).
# find_package(libsfdec/libsfenc/libsf-omx-il) will set option OFF if not found.

PKG_NAME="mpp"
PKG_VERSION="k1-bl-v2.2.11"
PKG_ARCH="riscv64"
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/spacemit-com/mpp"
PKG_URL="https://github.com/spacemit-com/mpp/archive/k1-bl-v2.2.11.tar.gz"
PKG_SHA256="acd90b2202eee9ec28e16e93dcea9171cb761b01db4dd29aa502017a3db3fd5c"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="SpacemiT Media Process Platform - hardware video codec userspace library"

PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="+sysroot"

# mpp CMakeLists uses cmake_minimum_required(2.8.8), but our cmake 4.x
# requires >= 3.5; this policy flag lets it configure anyway.
# GCC 16 defaults to C23 (stdbool.h), but mpp uses `typedef int bool` -> use gnu11.
PKG_CMAKE_OPTS_TARGET="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
                       -DRUN_PLATFORM=RISCV \
                       -DARCH_RISCV=Y \
                       -DCI_LOG_LEVEL=4 \
                       -DCMAKE_C_STANDARD=11 \
                       -DCMAKE_C_STANDARD_REQUIRED=ON"

makeinstall_target() {
  # Install libraries to both INSTALL and SYSROOT (ffmpeg needs -lspacemit_mpp)
  for destdir in ${INSTALL} ${SYSROOT_PREFIX}; do
    mkdir -p ${destdir}/usr/lib
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/mpi/libspacemit_mpp.so* ${destdir}/usr/lib/ 2>/dev/null || true
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/al/vcodec/v4l2/libv4l2_linlonv5v7_codec.so* ${destdir}/usr/lib/ 2>/dev/null || true

    # Install headers (needed by ffmpeg stcodec to compile)
    mkdir -p ${destdir}/usr/include
    cp -r ${PKG_BUILD}/include/* ${destdir}/usr/include/ 2>/dev/null || true
    cp -r ${PKG_BUILD}/mpi/include/* ${destdir}/usr/include/ 2>/dev/null || true
    cp -r ${PKG_BUILD}/utils/include/* ${destdir}/usr/include/ 2>/dev/null || true
    cp -r ${PKG_BUILD}/al/include/* ${destdir}/usr/include/ 2>/dev/null || true
  done

  # pkg-config file for ffmpeg's require_pkg_config
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  cat > ${SYSROOT_PREFIX}/usr/lib/pkgconfig/spacemit_mpp.pc <<EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: spacemit_mpp
Description: Spacemit Media Process Platform
Version: ${PKG_VERSION}
Libs: -L\${libdir} -lspacemit_mpp
Cflags: -I\${includedir}
EOF
}
