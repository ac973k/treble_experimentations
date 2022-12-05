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
aosp=""
phh=""

build_target="$1"
rebuild_release=""
if [ "$1" == "android-12.0" ];then
    manifest_url="https://android.googlesource.com/platform/manifest"
    aosp="android-12.1.0_r11"
    phh="android-12.0"

	# download manifest with the given version number
	tmp_manifest_source=$(mktemp -d)
	wget "https://github.com/ac973k/treble_experimentations/releases/download/v20221203/manifest.xml" -O $tmp_manifest_source/manifest.xml
	sed -i 's/<remote name="aosp" fetch=".." review="https:\/\/android-review.googlesource.com\/"\/>/<remote name="aosp" fetch="https:\/\/android.googlesource.com\/" review="https:\/\/android-review.googlesource.com\/"\/>/' $tmp_manifest_source/manifest.xml
	(cd $tmp_manifest_source; git init; git add manifest.xml; git commit -m "$1")
fi

if [ "$release" == true ];then
    [ -z "$version" ] && exit 1
    [ ! -f "$originFolder/release/config.ini" ] && exit 1
fi

if [ -n "$rebuild_release" ];then
	repo init -u "$tmp_manifest_source" -m manifest.xml --depth=1
else
	repo init -u "$manifest_url" -b $aosp --depth=1
	if [ -d .repo/local_manifests ] ;then
		( cd .repo/local_manifests; git fetch; git reset --hard; git checkout origin/$phh)
	else
		git clone https://github.com/ac973k/treble_manifest .repo/local_manifests -b $phh
	fi
fi
repo sync -c -j 1 --force-sync || repo sync -c -j1 --force-sync

repo forall -r '.*opengapps.*' -c 'git lfs fetch && git lfs checkout'
(cd device/phh/treble; git clean -fdx; if [ -f phh.mk ];then bash generate.sh phh;else bash generate.sh;fi)
(cd vendor/foss; git clean -fdx; bash update.sh)
if [ "$build_target" == "android-12.0" ] && grep -q lottie packages/apps/Launcher3/Android.bp;then
    (cd vendor/partner_gms; git am $originFolder/0001-Fix-SearchLauncher-for-Android-12.1.patch || true)
    (cd vendor/partner_gms; git am $originFolder/0001-Update-SetupWizard-to-A12.1-to-fix-fingerprint-enrol.patch || true)
fi
rm -f vendor/gapps/interfaces/wifi_ext/Android.bp


repo manifest -r > release/$rom_fp/manifest.xml
bash "$originFolder"/list-patches.sh
cp patches.zip release/$rom_fp/patches-for-developers.zip

if [ "$build_target" == "android-12.0" ];then
    (
        git clone https://github.com/ac973k/sas-creator
        cd sas-creator

        git clone https://github.com/phhusson/vendor_vndk -b android-10.0
    )

fi
