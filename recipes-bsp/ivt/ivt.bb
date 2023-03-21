DESCRIPTION = "IVT"
LICENSE = "BSD-3-Clause"

inherit deploy

S = "${WORKDIR}"

IVT_DCD_PTR = "00120000"
IVT_HSE_PTR = "00200000"
IVT_HSE_SYSIMG_PTR = "002F0000"
IVT_ATF_PTR = "00001200"
IVT_M7_PTR  = "00300000"
IVT_BOOT_CFG_M7 ="00000000"
IVT_BOOT_CFG_A53 ="00000001"

do_compile() {
    for plat in ${UBOOT_CONFIG}; do
        target_name="${PN}_${PV}-${plat}.bin"

        params="-o ${target_name}"

	if ${@bb.utils.contains('MACHINE_FEATURES', 'aptiv_secboot_parallel', 'true', 'false', d)}; then
            # atf pointer
            params="${params} -a ${IVT_ATF_PTR}"
            # Boot configuration word
            params="${params} -b ${IVT_BOOT_CFG_A53}"
        else
            # M7 app pointer
            params="${params} -a ${IVT_M7_PTR}"
            # Boot configuration word
            params="${params} -b ${IVT_BOOT_CFG_M7}"
        fi

        # HSE pointer
        params="${params} -h ${IVT_HSE_PTR}"

        # HSE SYS-IMG pointer
        params="${params} -s ${IVT_HSE_SYSIMG_PTR}"


        if [ "${plat}" = "s32g274ardb2" -o "${plat}" = "aptiv_cvc_sousa" ]; then
            # DCD pointer
            params="${params} -d ${IVT_DCD_PTR}"
        fi

        "${LAYER_PATH_aptiv-s32g-layer}"/scripts/create_ivt.sh ${params}

        md5sum="$(md5sum ${target_name} | awk '{print $1}')"
        echo "${md5sum}  ${nonarch_libdir}/firmware/${PN}-${plat}.bin" > "${target_name}.md5"
    done
}

do_install() {
    install -d "${D}${nonarch_libdir}/firmware"

    for plat in ${UBOOT_CONFIG}; do
        target_name="${PN}_${PV}-${plat}.bin"

        install -D -m 0644 "${S}/${target_name}" "${D}/${nonarch_libdir}/firmware/"
        install -D -m 0644 "${S}/${target_name}.md5" "${D}/${nonarch_libdir}/firmware/"
        ln -sf "${target_name}" "${D}/${nonarch_libdir}/firmware/${PN}-${plat}.bin"
        ln -sf "${target_name}.md5" "${D}/${nonarch_libdir}/firmware/${PN}-${plat}.bin.md5"
    done
}

do_deploy() {
    for plat in ${UBOOT_CONFIG}; do
        target_name="${PN}_${PV}-${plat}.bin"

        install -D -m 0644 "${B}/${target_name}" "${DEPLOYDIR}/"
        install -D -m 0644 "${B}/${target_name}.md5" "${DEPLOYDIR}/"
        ln -sf "${target_name}" "${DEPLOYDIR}/${PN}-${plat}.bin"
        ln -sf "${target_name}.md5" "${DEPLOYDIR}/${PN}-${plat}.bin.md5"
    done
}

do_patch() {
:
}

do_configure() {
:
}

FILES:${PN}:append = " \
    ${nonarch_libdir}/ \
    ${nonarch_libdir}/firmware/ \
    ${nonarch_libdir}/firmware/${PN}*.bin* \
    ${DEPLOY_DIR_IMAGE}/ \
    ${DEPLOY_DIR_IMAGE}/${PN}*.bin* \
"

addtask deploy after do_compile before do_install
EXPORT_FUNCTIONS do_deploy

COMPATIBLE_MACHINE = "aptiv-cvc"
