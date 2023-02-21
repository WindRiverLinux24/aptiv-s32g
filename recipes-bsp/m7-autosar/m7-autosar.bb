DESCRIPTION = "M7 firmware image"
LICENSE = "CLOSED"
PROVIDES += "virtual/autosarclassic"

inherit deploy

DEPENDS += "openssl-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

M7_IMAGE = "gcp_m7_app.bin"
M7_IMAGE_SIG ="gcp_m7_app.bin.signature"
TARGET_NAME = "${PN}_${PV}.bin"
MD5SUM = "78978b9080ca66ac77b76e4e4f011034"

SRC_URI:append:aptiv-cvc = " \
	file://${M7_IMAGE} \
"
SRC_URI[md5sum] = "${MD5SUM}"
SRC_URI[unpack] = "no"

S = "${WORKDIR}"

# 0x100 = 256
signature_size="256"

do_compile() {
    #sign gcp_m7_app.bin
    if [ -n "${FIP_SIGN_KEYDIR}" ]; then
        openssl dgst -sha1 -sign ${FIP_SIGN_KEYDIR}/${HSE_SEC_PRI_KEY} -out ${M7_IMAGE_SIG} ${M7_IMAGE}
    else
        openssl dgst -sha1 -sign ${DEPLOY_DIR_IMAGE}/${HSE_SEC_PRI_KEY} -out ${M7_IMAGE_SIG} ${M7_IMAGE}
    fi

    #install application header to gcp_m7_app.bin
    "${LAYER_PATH_aptiv-s32g-layer}"/scripts/add_app_header.sh \
        -i "${WORKDIR}/${M7_IMAGE}" \
        -o "${WORKDIR}/${M7_IMAGE}" \
        -l "34500000" \
        -e "34500000"

    m7_autosar_size=$(stat -c%s "${WORKDIR}/${M7_IMAGE}")
    m7_autosar_signed_size=$(expr $m7_autosar_size + ${signature_size})
    dd if=/dev/zero of=${M7_IMAGE}.tmp bs=1 count=$m7_autosar_signed_size conv=fsync
    dd if=${M7_IMAGE} of=${M7_IMAGE}.tmp bs=16 conv=notrunc,fsync
    #write signature data
    dd if=${M7_IMAGE_SIG} of=${M7_IMAGE}.tmp seek=$m7_autosar_size oflag=seek_bytes conv=notrunc,fsync
    mv ${M7_IMAGE}.tmp ${M7_IMAGE}

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

do_compile[depends] += "atf-s32g:do_deploy"

python () {
    if bb.utils.contains("MACHINE_FEATURES", "m7_boot m7_autosar_secboot", "true", "false", d) == "true":
        bb.fatal("m7_boot and aptiv-autosar-secboot template are not able to be enabled at the same time!")
    if d.getVar('HSE_SEC_ENABLED') == '1':
        bb.fatal("autosar secure boot and nxp-s32g secure boot are not able to be enabled at the same time!")
}
