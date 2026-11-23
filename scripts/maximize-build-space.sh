#!/usr/bin/env bash

set -euo pipefail

ROOT_RESERVE_MB="${ROOT_RESERVE_MB:-1024}"
TEMP_RESERVE_MB="${TEMP_RESERVE_MB:-100}"
SWAP_SIZE_MB="${SWAP_SIZE_MB:-4096}"
BUILD_MOUNT_PATH="${BUILD_MOUNT_PATH:-$GITHUB_WORKSPACE}"
MOUNT_OWNERSHIP="${MOUNT_OWNERSHIP:-runner:runner}"
PV_LOOP_PATH="${PV_LOOP_PATH:-/pv.img}"
TMP_PV_LOOP_PATH="${TMP_PV_LOOP_PATH:-/mnt/tmp-pv.img}"

REMOVE_DOTNET="${REMOVE_DOTNET:-false}"
REMOVE_ANDROID="${REMOVE_ANDROID:-false}"
REMOVE_HASKELL="${REMOVE_HASKELL:-false}"
REMOVE_CODEQL="${REMOVE_CODEQL:-false}"
REMOVE_DOCKER_IMAGES="${REMOVE_DOCKER_IMAGES:-false}"

VG_NAME=buildvg

echo "参数:"
echo "  Root reserve:      ${ROOT_RESERVE_MB} MiB"
echo "  Temp reserve:      ${TEMP_RESERVE_MB} MiB"
echo "  Swap space:        ${SWAP_SIZE_MB} MiB"
echo "  Mount path:        ${BUILD_MOUNT_PATH}"
echo "  Root PV loop path: ${PV_LOOP_PATH}"
echo "  Temp PV loop path: ${TMP_PV_LOOP_PATH}"
echo "  Removing: dotnet=${REMOVE_DOTNET} android=${REMOVE_ANDROID} haskell=${REMOVE_HASKELL} codeql=${REMOVE_CODEQL} docker=${REMOVE_DOCKER_IMAGES}"
echo

WORKSPACE_OWNER="$(stat -c '%U:%G' "${GITHUB_WORKSPACE}")"

echo "清理前可用空间:"
sudo df -h
echo

sudo mkdir -p "${BUILD_MOUNT_PATH}"

echo "删除预装软件..."
if [[ "${REMOVE_DOTNET}" == "true" ]]; then
  sudo rm -rf /usr/share/dotnet
fi
if [[ "${REMOVE_ANDROID}" == "true" ]]; then
  sudo rm -rf /usr/local/lib/android
fi
if [[ "${REMOVE_HASKELL}" == "true" ]]; then
  sudo rm -rf /opt/ghc
fi
if [[ "${REMOVE_CODEQL}" == "true" ]]; then
  sudo rm -rf /opt/hostedtoolcache/CodeQL
fi
if [[ "${REMOVE_DOCKER_IMAGES}" == "true" ]]; then
  sudo docker image prune --all --force
fi
echo "... 完成"
echo

echo "卸载并删除原 swap 文件..."
sudo swapoff -a
sudo rm -f /mnt/swapfile

echo "在根分区创建 LVM PV..."
ROOT_RESERVE_KB=$((ROOT_RESERVE_MB * 1024))
ROOT_FREE_KB=$(df --block-size=1024 --output=avail / | tail -1)
ROOT_LVM_SIZE_BYTES=$(( (ROOT_FREE_KB - ROOT_RESERVE_KB) * 1024 ))
sudo touch "${PV_LOOP_PATH}"
sudo fallocate -z -l "${ROOT_LVM_SIZE_BYTES}" "${PV_LOOP_PATH}"
ROOT_LOOP_DEV=$(sudo losetup --find --show "${PV_LOOP_PATH}")
sudo pvcreate -f "${ROOT_LOOP_DEV}"

echo "在临时盘 /mnt 创建 LVM PV..."
TEMP_RESERVE_KB=$((TEMP_RESERVE_MB * 1024))
TEMP_FREE_KB=$(df --block-size=1024 --output=avail /mnt | tail -1)
TEMP_LVM_SIZE_BYTES=$(( (TEMP_FREE_KB - TEMP_RESERVE_KB) * 1024 ))
sudo touch "${TMP_PV_LOOP_PATH}"
sudo fallocate -z -l "${TEMP_LVM_SIZE_BYTES}" "${TMP_PV_LOOP_PATH}"
TMP_LOOP_DEV=$(sudo losetup --find --show "${TMP_PV_LOOP_PATH}")
sudo pvcreate -f "${TMP_LOOP_DEV}"

echo "合并为卷组 ${VG_NAME}..."
sudo vgcreate "${VG_NAME}" "${TMP_LOOP_DEV}" "${ROOT_LOOP_DEV}"

echo "重建 swap..."
sudo lvcreate -L "${SWAP_SIZE_MB}M" -n swap "${VG_NAME}"
sudo mkswap "/dev/mapper/${VG_NAME}-swap"
sudo swapon "/dev/mapper/${VG_NAME}-swap"

echo "创建构建卷并挂载到 ${BUILD_MOUNT_PATH}..."
sudo lvcreate -l 100%FREE -n buildlv "${VG_NAME}"
sudo mkfs.ext4 -Enodiscard -m0 "/dev/mapper/${VG_NAME}-buildlv"
sudo mount "/dev/mapper/${VG_NAME}-buildlv" "${BUILD_MOUNT_PATH}"
sudo chown -R "${MOUNT_OWNERSHIP}" "${BUILD_MOUNT_PATH}"

if [[ ! -d "${GITHUB_WORKSPACE}" ]]; then
  sudo mkdir -p "${GITHUB_WORKSPACE}"
  sudo chown -R "${WORKSPACE_OWNER}" "${GITHUB_WORKSPACE}"
fi

echo
echo "清理后可用空间:"
sudo df -h