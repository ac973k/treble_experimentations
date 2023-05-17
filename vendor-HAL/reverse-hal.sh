#!/bin/bash

manifest="$1/manifest.xml"
if [ ! -f "$manifest" ];then
	manifest="$1/etc/vintf/manifest.xml"
fi
if [ ! -d "$1" -o ! -f "$manifest" ];then
	echo "Usage: $0 <vendor-folder>"
	exit 1
fi

rm -f broken
for HAL in $(xmlstarlet sel -t -m '//hal/name' -v . -n "$manifest" |grep -vE '^android\.hardware\.');do
	interface="$(
		xmlstarlet sel  \
			-t -m '//hal[./name/text()="'"$HAL"'"]' \
			-v './interface/name' "$manifest")"
	for version in $(xmlstarlet sel \
			-t -m '//hal[./name/text()="'"$HAL"'"]' \
			-v './version' -n "$manifest");do

	HAL=vendor.samsung.hardware.camera.device
	version=3.3
		class="$(echo "$interface" |sed -E 's/^I/BpHw/g')"
		class=BpHwSecCameraDeviceSession
		namespace="$(echo $HAL |sed -E 's/\./::/g')"
		namespace2="$(echo ${namespace}::V"$(echo $version |sed -e 's/\./_/g')")"
		prefix="$namespace2::$class"

		lib="$(echo "$1"/lib64/${HAL}@${version}.so)"
		if [ ! -f "$lib" ];then
			lib="$(echo "$1"/lib64/${HAL}@${version}_vendor.so)"
		fi
		if [ ! -f "$lib" -a -n "$2" ];then
			lib="$(echo "$2"/lib64/${HAL}@${version}.so)"
		fi
		if [ ! -f "$lib" -a -n "$2" ];then
			lib="$(echo "$2"/system/lib64/${HAL}@${version}.so)"
		fi
		if [ ! -f "$lib" ];then
			echo "Failed to find ${HAL}@${version}.so" >> broken
			continue
		fi
		echo $prefix
		nm -DC $lib |grep -F "T $prefix" | \
			sed -E "s/^.*$prefix:://g" | \
			grep -vE -e '\bping\b' -e '\binterfaceChain\b' -e '\binterfaceDescriptor\b' \
				-e '\bnotifySyspropsChanged\b' -e '\blinkToDeath\b' -e '\bunlinkToDeath\b' \
				-e '\bsetHALInstrumentation\b' \
				-e '\bgetDebugInfo\b' -e '\bdebug\b' \
				-e '\bgetHashChain\b' -e "^$class\(android::sp<android::hardware::IBinder> const&\)" | \
			sed -E 's/(, )?std::__1::function<void \((.*)\)>\).*/\) generates \(\2\)/g' | \
			sed -E 's/android::hardware::hidl_string const\&/string/g' | \
			sed -E 's/android::hardware::hidl_vec<([^>]*)> const\&/vec<\1>/g' | \
			grep -vE '^_hidl_' \
			> $HAL@$version.hal
	done
done
