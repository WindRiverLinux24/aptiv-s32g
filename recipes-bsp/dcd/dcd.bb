DESCRIPTION = "DCD"
LICENSE = "BSD-3-Clause"

inherit deploy

S = "${WORKDIR}"

do_compile() {
    for plat in ${UBOOT_CONFIG}; do
        target_name="${PN}_${PV}-${plat}.bin"

        "${LAYER_PATH_aptiv-s32g-layer}"/scripts/create_dcd.sh \
            -o "${target_name}" \
            -p "${plat}"

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

EXCLUDE_FROM_WORLD = "1"

COMPATIBLE_MACHINE = "aptiv-cvc"
