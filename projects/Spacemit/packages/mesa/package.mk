# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)

# Mesa with the SpacemiT K1 gallium pvr driver (vendor mesa3d fork, k1-bl-v2.2.y)
# The pvr frontend dlopens libpvr_dri_support.so from img-gpu-powervr; the
# DRI driver name is aliased to "spacemit" to match the vendor spacemit DRM/KMS
# display driver.
#
# K1 uses the GBM + GLES path (DISPLAYSERVER=no, no wayland/x11), so mesa is
# built with an empty platforms list and no wayland dependency - matching the
# upstream LibreELEC mesa recipe behaviour for the non-wl/x11 case.

PKG_NAME="mesa"
PKG_VERSION="24.3.0"
PKG_ARCH="riscv64"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/spacemit-com/mesa3d"
# Coupled to the other K1 vendor packages: see "Version pinning" in
# projects/Spacemit/options before changing the version.
# Tested k1-bl-v2.2.y commit (newer than the k1-bl-v2.2.10-release tag).
PKG_COMMIT="5a37ce2f58070017d0b25e7434232dff457dee34"
PKG_URL="https://github.com/spacemit-com/mesa3d/archive/${PKG_COMMIT}.tar.gz"
PKG_SHA256="08b4dc62b22ed4dde8d321d468e959e83631003f2cdb74a55464e70b07bce8d5"
PKG_DEPENDS_HOST="toolchain:host expat:host libdrm:host Mako:host pyyaml:host spirv-tools:host"
PKG_DEPENDS_TARGET="toolchain expat libdrm Mako:host pyyaml:host img-gpu-powervr"
PKG_LONGDESC="Mesa with PowerVR (pvr) gallium driver for SpacemiT K1"

get_graphicdrivers

PKG_MESON_OPTS_TARGET="-Dgallium-drivers=pvr,swrast \
                       -Dgallium-extra-hud=false \
                       -Dgallium-rusticl=false \
                       -Dshader-cache=enabled \
                       -Dopengl=true \
                       -Dgbm=enabled \
                       -Degl=enabled \
                       -Dvalgrind=disabled \
                       -Dlibunwind=disabled \
                       -Dlmsensors=disabled \
                       -Dbuild-tests=false \
                       -Dmicrosoft-clc=disabled \
                       -Dplatforms= \
                       -Dglx=disabled \
                       -Dvulkan-drivers=[] \
                       -Dgallium-pvr-alias=spacemit \
                       -Dllvm=disabled \
                       -Dglvnd=false \
                       -Dc_args=-D__STDC_NO_THREADS__"
