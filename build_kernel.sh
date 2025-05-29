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

# Pilih defconfig berdasarkan apakah ada file/folder KernelSU*
if compgen -G "KernelSU*" > /dev/null; then
    DEFCONFIG=a34x-susfs_defconfig
else
    DEFCONFIG=a34x_defconfig
fi

# Jalankan build
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y LLVM=1 LLVM_IAS=1 ${DEFCONFIG}
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y LLVM=1 LLVM_IAS=1 -j$(nproc)
