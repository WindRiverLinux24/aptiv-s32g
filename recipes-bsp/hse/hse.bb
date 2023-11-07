DESCRIPTION = "HSE firmware"
LICENSE = "CLOSED"

inherit deploy
include version_rev.inc

SRC_URI = "${BASEURI}/${HSE_IMAGE}"
SRC_URI[md5sum] = "${MD5SUM}"
SRC_URI[unpack] = "no"

TARGET_NAME="${PN}_${PV}.bin"

S = "${WORKDIR}"

do_compile() {
    echo "${MD5SUM}  ${nonarch_libdir}/firmware/${PN}.bin" > "${WORKDIR}/${TARGET_NAME}.md5"
}

do_install() {
    install -D -m 0644 "${S}/${HSE_IMAGE}" "${D}/${nonarch_libdir}/firmware/${TARGET_NAME}"
    install -D -m 0644 "${S}/${TARGET_NAME}.md5" "${D}/${nonarch_libdir}/firmware/"
    ln -sf "${TARGET_NAME}" "${D}/${nonarch_libdir}/firmware/${PN}.bin"
    ln -sf "${TARGET_NAME}.md5" "${D}/${nonarch_libdir}/firmware/${PN}.bin.md5"
}

do_deploy() {
    install -D -m 0644 "${B}/${HSE_IMAGE}" "${DEPLOYDIR}/${TARGET_NAME}"
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

COMPATIBLE_MACHINE = "aptiv-cvc"
