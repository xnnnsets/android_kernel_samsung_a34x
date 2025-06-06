#!/bin/bash

# ========================[ KONFIGURASI TOOLCHAIN & ENV ]========================

# Path toolchain Clang
export TOOLCHAIN_DIR=$(pwd)/toolchain/clang/host/linux-x86/clang-r547379/bin
export PATH=$TOOLCHAIN_DIR:$PATH
export CROSS_COMPILE=${TOOLCHAIN_DIR}/aarch64-linux-gnu-
export CC=${TOOLCHAIN_DIR}/clang
export CLANG_TRIPLE=aarch64-linux-gnu-

# Target konfigurasi build
export ARCH=arm64
export PLATFORM_VERSION=14
export TARGET_SOC=mt6877
export TARGET_BUILD_VARIANT=user
export PROJECT_NAME=a34x
export TARGET_PRODUCT=a34xxx

# Opsi compiler tambahan
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# ===========================[ PILIHAN DEFCONFIG ]==============================

DEFCONFIG_DEFAULT=a34x_defconfig
DEFCONFIG_SUSFS=a34x-susfs_defconfig

# Deteksi apakah KernelSU ada
if compgen -G "KernelSU*" > /dev/null; then
    DEFCONFIG_BUILD=${DEFCONFIG_SUSFS}
    echo "🔍 KernelSU terdeteksi. Menggunakan defconfig: ${DEFCONFIG_SUSFS}"
else
    DEFCONFIG_BUILD=${DEFCONFIG_DEFAULT}
    echo "ℹ️  KernelSU tidak terdeteksi. Menggunakan defconfig: ${DEFCONFIG_DEFAULT}"
fi

# ===============[ LANGKAH 1: BUILD CONFIG_DATA.H DARI DEFAULT CONFIG ]==========

echo "⚙️  Membuat config_data.h dan config_data.gz dari ${DEFCONFIG_DEFAULT}..."
make O=out_default KCFLAGS="$KCFLAGS" CONFIG_SECTION_MISMATCH_WARN_ONLY=$CONFIG_SECTION_MISMATCH_WARN_ONLY LLVM=1 LLVM_IAS=1 ${DEFCONFIG_DEFAULT}
make O=out_default LLVM=1 LLVM_IAS=1 KCFLAGS="$KCFLAGS" CONFIG_SECTION_MISMATCH_WARN_ONLY=$CONFIG_SECTION_MISMATCH_WARN_ONLY MANUAL_CONFIG=$(pwd)/arch/arm64/configs/${DEFCONFIG_DEFAULT} kernel/configs.o

# ===============[ LANGKAH 2: BUILD KERNEL MENGGUNAKAN CONFIG YANG DIPILIH ]=====

echo "🔨 Build kernel dengan konfigurasi: ${DEFCONFIG_BUILD}"
make O=out KCFLAGS="$KCFLAGS" CONFIG_SECTION_MISMATCH_WARN_ONLY=$CONFIG_SECTION_MISMATCH_WARN_ONLY LLVM=1 LLVM_IAS=1 ${DEFCONFIG_BUILD}
make O=out KCFLAGS="$KCFLAGS" CONFIG_SECTION_MISMATCH_WARN_ONLY=$CONFIG_SECTION_MISMATCH_WARN_ONLY LLVM=1 LLVM_IAS=1 -j$(nproc)
# ===============[ LANGKAH 3: OVERRIDE CONFIG DATA AGAR SESUAI DEFAULT ]=========

echo "📝 Override config_data agar /proc/config.gz mencerminkan ${DEFCONFIG_DEFAULT}"
cp -vf out_default/kernel/config_data.h out/kernel/
cp -vf out_default/kernel/config_data.gz out/kernel/
cp -vf out_default/kernel/configs.o out/kernel/
cp -vf out_default/kernel/.config_data.gz.cmd out/kernel/ || true  # Optional

# ===============[ LANGKAH 4: BUILD IMAGE.GZ UNTUK ANDROID BOOT ]================

echo "📦 Membuat Image.gz dengan konfigurasi embed dari ${DEFCONFIG_DEFAULT}"
make O=out KCFLAGS="$KCFLAGS" CONFIG_SECTION_MISMATCH_WARN_ONLY=$CONFIG_SECTION_MISMATCH_WARN_ONLY LLVM=1 LLVM_IAS=1 Image Image.gz
# ===========================[ BUILD SELESAI ]===================================

echo "✅ Build kernel selesai!"
echo "📁 File kernel: out/arch/arm64/boot/Image.gz"
echo "🔍 /proc/config.gz akan menampilkan konfigurasi dari ${DEFCONFIG_DEFAULT}"

