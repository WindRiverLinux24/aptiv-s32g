DESCRIPTION = "M7 firmware image"
LICENSE = "CLOSED"
PROVIDES += "virtual/autosarclassic"

include autosar-classic-version.inc
inherit deploy

PV = "${ARTIFACTORYPV}"

TARGET_NAME = "${PN}_${PV}.bin"

SRC_URI = "${BASEURI}/${ARTIFACTORYPV}/${M7_IMAGE}"
SRC_URI[md5sum] = "${MD5SUM}"
SRC_URI[unpack] = "no"

S = "${WORKDIR}"

do_compile() {
    "${LAYER_PATH_aptiv-s32g-layer}"/scripts/add_app_header.sh \
        -i "${WORKDIR}/${M7_IMAGE}" \
        -o "${WORKDIR}/${M7_IMAGE}" \
        -l "34500000" \
        -e "34500000"

    md5sum="$(md5sum ${WORKDIR}/${M7_IMAGE} | awk '{print $1}')"
    echo "${md5sum}  ${nonarch_libdir}/firmware/${PN}.bin" > "${WORKDIR}/${TARGET_NAME}.md5"
}

do_install() {
    install -D -m 0644 "${S}/${M7_IMAGE}" "${D}/${nonarch_libdir}/firmware/${TARGET_NAME}"
    install -D -m 0644 "${S}/${TARGET_NAME}.md5" "${D}/${nonarch_libdir}/firmware/"
    ln -sf "${TARGET_NAME}" "${D}/${nonarch_libdir}/firmware/${PN}.bin"
    ln -sf "${TARGET_NAME}.md5" "${D}/${nonarch_libdir}/firmware/${PN}.bin.md5"
}

do_deploy() {
    install -D -m 0644 "${B}/${M7_IMAGE}" "${DEPLOYDIR}/${TARGET_NAME}"
    install -D -m 0644 "${B}/${TARGET_NAME}.md5" "${DEPLOYDIR}/"
    ln -sf "${TARGET_NAME}" "${DEPLOYDIR}/${PN}.bin"
    ln -sf "${TARGET_NAME}.md5" "${DEPLOYDIR}/${PN}.bin.md5"
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

python () {
    if bb.utils.contains("MACHINE_FEATURES", "m7_boot m7_autosar_boot", True, False, d):
        bb.fatal("m7_boot and aptiv-autosar-boot template are not able to be enabled at the same time!")
    if bb.utils.contains("MACHINE_FEATURES", "m7_autosar_boot", True, False, d):
        if d.getVar('HSE_SEC_ENABLED') == '1' or \
                bb.utils.contains("BBLAYERS", "s32g-secure-boot", True, False, d):
            bb.fatal("autosar secure boot and nxp-s32g secure boot are not able to be used at the same time!")
}

COMPATIBLE_MACHINE = "aptiv-cvc"
