. build/envsetup.sh

rom_fp="$(date +%y%m%d)"
originFolder="$(dirname "$(readlink -f -- "$0")")"
OUT="/home/daniil/AndroidSources/AOSP12/out/target/product/phhgsi_arm64_ab"
mkdir -p release/$rom_fp/

lunch treble_arm64_bvS-userdebug

make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp installclean
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp -j5 systemimage
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy

xz -c $OUT/system.img -T0 > release/$rom_fp/system-squeak-arm64-ab-vanilla.img.xz

cd sas-creator

sudo bash lite-adapter.sh 64
xz -c s.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-vanilla.img.xz
sudo bash securize.sh s.img
xz -c s-secure.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-vanilla-secure.img.xz


lunch treble_arm64_bgS-userdebug

make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp installclean
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp -j5 systemimage
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy

xz -c $OUT/system.img -T0 > release/$rom_fp/system-squeak-arm64-ab-gapps.img.xz

cd sas-creator

sudo bash lite-adapter.sh 64
xz -c s.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-gapps.img.xz
sudo bash securize.sh s.img
xz -c s-secure.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-gapps-secure.img.xz


lunch treble_arm64_boS-userdebug

make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp installclean
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp -j5 systemimage
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy

xz -c $OUT/system.img -T0 > release/$rom_fp/system-squeak-arm64-ab-gogapps.img.xz

cd sas-creator

sudo bash lite-adapter.sh 64
xz -c s.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-gogapps.img.xz
sudo bash securize.sh s.img
xz -c s-secure.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-gogapps-secure.img.xz


lunch treble_arm64_bfS-userdebug

make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp installclean
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp -j5 systemimage
make RELAX_USES_LIBRARY_CHECK=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy

xz -c $OUT/system.img -T0 > release/$rom_fp/system-squeak-arm64-ab-floss.img.xz

cd sas-creator

sudo bash lite-adapter.sh 64
xz -c s.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-floss.img.xz
sudo bash securize.sh s.img
xz -c s-secure.img -T0 > ../release/$rom_fp/system-squeak-arm64-ab-vndklite-floss-secure.img.xz
