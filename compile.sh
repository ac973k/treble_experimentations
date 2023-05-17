#!/bin/bash

rom_fp="$(date +%y%m%d)"
originFolder="$(dirname "$(readlink -f -- "$0")")"
mkdir -p release/$rom_fp/
set -e

if [ -z "$USER" ];then
	export USER="$(id -un)"
fi
export LC_ALL=C

(cd device/phh/treble; git clean -fdx; bash generate.sh)

. build/envsetup.sh


lunch treble_arm64_bvS-userdebug

make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp installclean
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp -j5 systemimage
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy

xz -c $OUT/system.img -T0 > release/$rom_fp/system-td-arm64-ab-vanilla.img.xz


cd sas-creator
sudo bash lite-adapter.sh 64
xz -c s.img -T0 > ../release/$rom_fp/system-td-arm64-ab-vndklite-vanilla.img.xz
