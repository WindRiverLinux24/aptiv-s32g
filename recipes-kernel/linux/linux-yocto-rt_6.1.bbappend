KBRANCH:aptiv-cvc  = "v6.1/standard/preempt-rt/nxp-sdk-5.15/nxp-s32g"
COMPATIBLE_MACHINE:aptiv-cvc = "aptiv-cvc"
TARGET_SUPPORTED_KTYPES:aptiv-cvc = "preempt-rt"
FILESEXTRAPATHS:prepend:aptiv-cvc := "${THISDIR}/files:"

SRC_URI:append:aptiv-cvc = " \
	file://0001-dts-Aptiv-change-scmi-buf.patch \
"

# Add public key to ATF dtb for multiple platforms
fitimage_assemble:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${VAULT_ENABLE}" != "1" ]; then
			for dtb in ${ATF_DTB}; do
				${UBOOT_MKIMAGE_SIGN} \
					${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
					-f $1 \
					arch/${ARCH}/boot/$2

				cp -P ${STAGING_DATADIR}/atf-${dtb} ${B}
				add_key_to_atf="-K ${B}/atf-${dtb}"

				${UBOOT_MKIMAGE_SIGN} \
					${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
					-F -k "${UBOOT_SIGN_KEYDIR}" \
					$add_key_to_atf \
					-r arch/${ARCH}/boot/$2
			done
		fi
	fi
}

do_deploy:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		cd ${B}
		install -m 0644 ${KERNEL_OUTPUT_DIR}/fitImage $deployDir/

		for dtb in ${ATF_DTB}; do
			install -m 0644 ${B}/atf-${dtb} $deployDir/
		done

		if [ "${OSTREE_USE_FIT}" = "1" ]; then
			cp -af ${UBOOT_SIGN_KEYDIR}/${UBOOT_SIGN_KEYNAME}.key $deployDir/
			cp -af ${UBOOT_SIGN_KEYDIR}/${UBOOT_SIGN_IMG_KEYNAME}.key $deployDir/
		fi
	fi
}

# Emit signature of the fitImage ITS kernel section
fitimage_emit_section_kernel:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${ATF_SIGN_ENABLE}" = "1" -a "${FIT_SIGN_INDIVIDUAL}" = "1" -a -n "$kernel_sign_keyname" ] ; then
			sed -i '$ d' $1
			cat << EOF >> $1
		                signature-1 {
		                        algo = "$kernel_csum,$kernel_sign_algo";
		                        key-name-hint = "$kernel_sign_keyname";
		                };
		        };
EOF
		fi
	fi
}

# Emit signature of the fitImage ITS DTB section
fitimage_emit_section_dtb:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${ATF_SIGN_ENABLE}" = "1" -a "${FIT_SIGN_INDIVIDUAL}" = "1" -a -n "$dtb_sign_keyname" ] ; then
			sed -i '$ d' $1
			cat << EOF >> $1
		                signature-1 {
		                        algo = "$dtb_csum,$dtb_sign_algo";
		                        key-name-hint = "$dtb_sign_keyname";
		                };
		        };
EOF
		fi
	fi
}

# Emit signature of the fitImage ITS u-boot script section
fitimage_emit_section_boot_script:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${ATF_SIGN_ENABLE}" = "1" -a "${FIT_SIGN_INDIVIDUAL}" = "1" -a -n "$bootscr_sign_keyname" ] ; then
			sed -i '$ d' $1
			cat << EOF >> $1
		                signature-1 {
		                        algo = "$bootscr_csum,$bootscr_sign_algo";
		                        key-name-hint = "$bootscr_sign_keyname";
		                };
		        };
EOF
		fi
	fi
}

# Emit signature of the fitImage ITS ramdisk section
fitimage_emit_section_ramdisk:append:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${ATF_SIGN_ENABLE}" = "1" -a "${FIT_SIGN_INDIVIDUAL}" = "1" -a -n "$ramdisk_sign_keyname" ] ; then
			sed -i '$ d' $1
			cat << EOF >> $1
		                signature-1 {
		                        algo = "$ramdisk_csum,$ramdisk_sign_algo";
		                        key-name-hint = "$ramdisk_sign_keyname";
		                };
		        };
EOF
		fi
	fi
}

# set key name of the fitImage ITS configuration section
fitimage_emit_section_config:prepend:aptiv-cvc() {
	if ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', 'true', 'false', d)}; then
		if [ "${ATF_SIGN_ENABLE}" = "1" ] ; then
			conf_sign_keyname="${UBOOT_SIGN_KEYNAME}"
		fi
	fi
}

python __anonymous () {
    if bb.utils.contains("MACHINE_FEATURES", "m7_autosar_secboot", "true", "false", d) == "true":
        atf_pn = 'atf-s32g'
        if d.getVar('INITRAMFS_IMAGE_BUNDLE') == "1":
            d.appendVarFlag('do_assemble_fitimage_initramfs', 'depends', ' %s:do_populate_sysroot' % atf_pn)
        else:
            d.appendVarFlag('do_assemble_fitimage', 'depends', ' %s:do_populate_sysroot' % atf_pn)
}
