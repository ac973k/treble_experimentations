#!/bin/bash

rom_fp="$(date +%y%m%d)"
originFolder="$(dirname "$(readlink -f -- "$0")")"
mkdir -p release/$rom_fp/
set -e

if [ -z "$USER" ];then
	export USER="$(id -un)"
fi
export LC_ALL=C

manifest_url="https://android.googlesource.com/platform/manifest"
aosp="android-13.0.0_r41"
phh="android-13.0"

build_target="$1"
manifest_url="https://android.googlesource.com/platform/manifest"

repo init -u "$manifest_url" -b $aosp --depth=1
if [ -d .repo/local_manifests ] ;then
	( cd .repo/local_manifests; git fetch; git reset --hard; git checkout origin/$phh)
else
	git clone https://github.com/ac973k/treble_manifest .repo/local_manifests -b $phh
fi
repo sync -c -j 1 --force-sync || repo sync -c -j1 --force-sync

repo manifest -r > release/$rom_fp/manifest.xml
bash "$originFolder"/list-patches.sh
cp patches.zip release/$rom_fp/patches-for-developers.zip

git clone https://github.com/TrebleDroid/sas-creator
cd sas-creator

git clone https://github.com/phhusson/vendor_vndk -b android-10.0
