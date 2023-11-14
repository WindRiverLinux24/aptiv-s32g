FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/atf-s32g-aptiv:"

PLATFORM:aptiv-cvc-fl = " aptiv_cvc_fl"

AUTOSAR_SEC_PATCHES = "file://0001-s32-extend-the-DTB-size-for-BL33.patch \
			file://0001-dts-s32-extend-the-hse-reserve-memory-to-8-MB.patch \
"

ATF_HVP_PATCH="${@bb.utils.contains('MACHINE_FEATURES', 'hvp', 'file://0005-aptiv-s32g-atf-add-xrdc.patch', '', d)}"

SRC_URI:append:aptiv-cvc = " \
	file://0003-atf-s32g-Set-CAN-clock-to-FOSC-and-40MHz.patch \
	file://0007-aptiv-s32g-atf-s32g-Patch-PFE1-2-SGMII-MDIO-Bus-for-.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-aptiv-cvc-fl-dts-add-mmc-sel-gpio-hog.patch \
	${ATF_HVP_PATCH} \
	${@bb.utils.contains('MACHINE_FEATURES', 'disable_atf_i2c4', \
	'file://0001-aptiv-cvc-fl-dts-prohibit-pmic-devices-on-i2c4-bus.patch', '', d)} \
"
HVP_EXTRA_OEMAKE="${@bb.utils.contains('MACHINE_FEATURES', 'hvp', 'S32_HAS_HV=1', '', d)}"
EXTRA_OEMAKE:append:aptiv-cvc = " ${HVP_EXTRA_OEMAKE}"

get_u32 () {
	local file="$1"
	local offset="$2"
	printf "%s" $(od --address-radix=n --format=u4 --skip-bytes="$offset" --read-bytes=4 "$file")
}

str2bin () {
	# write binary as little endian
	print_cmd=`which printf`
	$print_cmd $(echo $1 | sed -E -e 's/(..)(..)(..)(..)/\4\3\2\1/' -e 's/../\\x&/g')
}

# This is a workaround, because Aptiv autosar doesn't copy the correct size of BL2 image,
# the last 64 bytes is missed. make a workaround to extend BL2 size so that Aptiv autosar
# copy the whole BL2 code into internal RAM.
bl2_extend_size="512"
# bl2 size is in application header, offset from the beginning of fip.s32 is 0x120c
bl2_size_off="4620"

do_deploy:append() {
    if ${@bb.utils.contains("MACHINE_FEATURES", "m7_autosar_boot", "true", "false", d)}; then
        for type in ${BOOT_TYPE}; do
            for plat in ${PLATFORM}; do
                ATF_BINARIES="${B}/$type/${plat}/${BUILD_TYPE}"
                bl2_size=$(get_u32 "${ATF_BINARIES}/fip.s32" ${bl2_size_off})
                bl2_size=$(expr $bl2_size + ${bl2_extend_size})
                bl2_size=$(printf "%08x" $bl2_size)
                str2bin $bl2_size | dd of="${ATF_BINARIES}/fip.s32" count=4 seek=${bl2_size_off} \
                                        conv=notrunc,fsync status=none iflag=skip_bytes,count_bytes oflag=seek_bytes
	            cp -v ${ATF_BINARIES}/fip.s32 ${DEPLOY_DIR_IMAGE}/atf-${plat}.s32
            done
        done
    fi
}

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
