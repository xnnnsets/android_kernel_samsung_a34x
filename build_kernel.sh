#!/bin/bash

# Konfigurasi toolchain dan environment
export PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r547379/bin:$PATH
export CROSS_COMPILE=$(pwd)/toolchain/clang/host/linux-x86/clang-r547379/bin/aarch64-linux-gnu-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r547379/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export PLATFORM_VERSION=14
export TARGET_SOC=mt6877
export TARGET_BUILD_VARIANT=user
export PROJECT_NAME=a34x
export TARGET_PRODUCT=a34xxx

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

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

# Jalankan build
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y LLVM=1 LLVM_IAS=1 ${DEFCONFIG_BUILD}
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y LLVM=1 LLVM_IAS=1 -j$(nproc)
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y LLVM=1 LLVM_IAS=1 MANUAL_CONFIG=$(pwd)/arch/arm64/configs/${DEFCONFIG_DEFAULT} Image Image.gz
