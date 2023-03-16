FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/atf-s32g-aptiv:"

PLATFORM:aptiv_cvc_sousa = " aptiv_cvc_sousa"
PLATFORM:aptiv-cvc-fl = " aptiv_cvc_fl"

AUTOSAR_SEC_PATCHES = "file://0001-s32-extend-the-DTB-size-for-BL33.patch \
			file://0001-dts-s32-extend-the-hse-reserve-memory-to-8-MB.patch \
"

SRC_URI:append:aptiv-cvc = " \
	file://0001-s32g-Aptiv-move-imem_cfg.c-into-the-board-mk-files.patch \
	file://0002-s32g-Aptiv-add-ddr-parameter-files-of-CVC-board.patch \
	file://0003-atf-s32g-Set-CAN-clock-to-FOSC-and-40MHz.patch \
	file://0004-aptiv-s32g-atf-add-aptiv-cvc-dts-file.patch \
	file://0005-aptiv-s32g-atf-add-xrdc.patch \
	file://0006-aptiv-set-S32_VR5510-for-aptiv-CVC-platform.patch \
	file://0007-aptiv-s32g-atf-s32g-Patch-PFE1-2-SGMII-MDIO-Bus-for-.patch \
	file://0008-aptiv-cvc-fl-add-support-for-Aptiv-CVC-FL-board.patch \
	file://0009-aptiv-cvc-fl-dts-add-mmc-sel-gpio-hog.patch \
	${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', '${AUTOSAR_SEC_PATCHES}', '', d)} \
"

EXTRA_OEMAKE:append:aptiv-cvc = " S32_HAS_HV=1"

COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"

# 0x100 = 256
signature_size="256"

str2bin () {
	# write binary as little endian
	printf $(echo $1 | sed -E -e 's/(..)(..)(..)(..)/\4\3\2\1/' -e 's/../\\x&/g')
}

do_install:append() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		unset i j
		for type in ${BOOT_TYPE}; do
			for plat in ${PLATFORM}; do
				i=$(expr $i + 1);
				for dtb in ${ATF_DTB}; do
					j=$(expr $j + 1)
					if  [ $j -eq $i ]; then
						cd ${B}/${type}/${plat}/${BUILD_TYPE}/fdts
						install -Dm 0644 ${dtb} ${D}${datadir}/atf-${dtb}
					fi
				done
				unset j
			done
			unset i
		done
	fi
}

do_deploy:prepend() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		install -d ${DEPLOY_DIR_IMAGE}

		unset LDFLAGS
		unset CFLAGS
		unset CPPFLAGS

		unset i j
		for type in ${BOOT_TYPE}; do
			for plat in ${PLATFORM}; do
				build_base="${B}/$type/"
				bl33_dir="${DEPLOY_DIR_IMAGE}/${plat}_${type}"
				if [ "$type" = "sd" ]; then
					bl33_dir="${DEPLOY_DIR_IMAGE}/${plat}"
				fi
				bl33_bin="${bl33_dir}/${UBOOT_BINARY}"
				uboot_cfg="${bl33_dir}/${UBOOT_CFGOUT}"
				i=$(expr $i + 1);
				for dtb in ${ATF_DTB}; do
					j=$(expr $j + 1)
					if  [ $j -eq $i ]; then
						cp -f ${DEPLOY_DIR_IMAGE}/atf-${dtb} ${B}/${type}/${plat}/${BUILD_TYPE}/fdts/${dtb}
						oe_runmake -C ${S} BUILD_BASE=$build_base PLAT=${plat} BL33=$bl33_bin MKIMAGE_CFG=$uboot_cfg MKIMAGE=mkimage all
					fi
				done
				unset j
			done
			unset i
		done
	fi
}

do_deploy:append() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		for type in ${BOOT_TYPE}; do
			for plat in ${PLATFORM}; do
				ATF_BINARIES="${B}/$type/${plat}/${BUILD_TYPE}"
				hse_keys_dir="${B}/${HSE_SEC_KEYS}"

				if [ -n "${FIP_SIGN_KEYDIR}" ]; then
					hse_pri_key="${FIP_SIGN_KEYDIR}/${HSE_SEC_PRI_KEY}"
				else
					hse_pri_key="${hse_keys_dir}/${HSE_SEC_PRI_KEY}"
				fi

				if [ ! -d "${hse_keys_dir}" ]; then
					install -d ${hse_keys_dir}
					if [ -z "${FIP_SIGN_KEYDIR}" ]; then
						openssl genrsa -out ${hse_keys_dir}/${HSE_SEC_PRI_KEY}
						cp -f ${hse_keys_dir}/${HSE_SEC_PRI_KEY} ${DEPLOY_DIR_IMAGE}/
					fi
					openssl rsa -in ${hse_pri_key} -outform DER -pubout -out ${hse_keys_dir}/${HSE_SEC_PUB_KEY}
					openssl rsa -in ${hse_pri_key} -outform PEM -pubout -out ${hse_keys_dir}/${HSE_SEC_PUB_KEY_PEM}
				fi

				fip_bin_size=$(stat -c%s "${ATF_BINARIES}/fip.bin")
				fip_bin_signed_size=$(expr $fip_bin_size + ${signature_size})
				dd if=/dev/zero of=${ATF_BINARIES}/fip.bin.tmp bs=1 count=$fip_bin_signed_size conv=fsync
				dd if=${ATF_BINARIES}/fip.bin of=${ATF_BINARIES}/fip.bin.tmp bs=16 conv=notrunc,fsync

				#sign fip.bin
				openssl dgst -sha1 -sign ${hse_pri_key} -out ${ATF_BINARIES}/${HSE_SEC_SIGN_DST} ${ATF_BINARIES}/fip.bin
				#write signature data
				dd if=${ATF_BINARIES}/${HSE_SEC_SIGN_DST} of=${ATF_BINARIES}/fip.bin.tmp seek=$fip_bin_size oflag=seek_bytes conv=notrunc,fsync

				mv ${ATF_BINARIES}/fip.bin.tmp ${ATF_BINARIES}/fip.bin

				#get layout of fip.s32
				mkimage -l ${ATF_BINARIES}/fip.s32 > ${ATF_BINARIES}/atf_layout 2>&1
				fip_dd_offset=`cat ${ATF_BINARIES}/atf_layout | grep Application | awk -F ":" '{print $3}' | awk -F " " '{print $1}'`
				dd if=${ATF_BINARIES}/fip.bin of=${ATF_BINARIES}/fip.s32 seek=`printf "%d" ${fip_dd_offset}` oflag=seek_bytes conv=notrunc,fsync

				#copy pub key and signed fip.bin to DEPLOY_DIR_IMAGE
				cp -v ${hse_keys_dir}/${HSE_SEC_PUB_KEY} ${DEPLOY_DIR_IMAGE}/
				cp -v ${hse_keys_dir}/${HSE_SEC_PUB_KEY_PEM} ${DEPLOY_DIR_IMAGE}/
				cp -v ${ATF_BINARIES}/fip.bin ${DEPLOY_DIR_IMAGE}/atf-${plat}.s32.signature
				cp -v ${ATF_BINARIES}/fip.s32 ${DEPLOY_DIR_IMAGE}/atf-${plat}.s32
			done
		done
	fi
}

KERNEL_PN = "${@d.getVar('PREFERRED_PROVIDER_virtual/kernel')}"
python () {
    if bb.utils.contains("MACHINE_FEATURES", "m7_autosar_secboot", "true", "false", d) == "true":
        # Make "bitbake atf-s32g -cdeploy" depends the signed dtb files
        d.appendVarFlag('do_deploy', 'depends', ' %s:do_deploy' % d.getVar('KERNEL_PN'))
}

FILES:${PN} = "/boot ${datadir}"
