#!/bin/bash

set -eE -o pipefail

# DCD image structure
# -------------------
#
# Address         | Size          | Name
# Offset          | in bytes      |
# ----------------|---------------|---------------------------------------
# 0x00            | 4             | DCD header
# 0x04            | DCD length    | DCD data
# DCD length + 4  | 16            | GMAC
#
# DCD header
# ----------
#
# Byte 0    | Byte 1 | Byte 2 | Byte 3
# ----------|--------|--------|--------------
# Tag = D2h | Length          | Version = 60h

trap "exit 2" ERR

declare dcd=""
declare platform="aptiv_cvc_sousa"

while getopts "do:p:x" opt; do
    case "${opt}" in
        o)
            # DCD output binary
            dcd="${OPTARG}"
            ;;
        p)
            platform="${OPTARG}"
            ;;
        x)
            # Debug output
            set -x
            ;;
        *)
            # All other options are treated as failure
            exit 1
            ;;
    esac
done

if [[ -z "${dcd}" ]]; then
    exit 1
fi

# prepare empty DCD image fitting biggest DCD
# (4 bytes header - 48 bytes data - 16 bytes GMAC = 72 bytes)
dd if=/dev/zero of="${dcd}" bs=72 count=1

if [[ "${platform}" == "s32g274ardb2" ]]; then
    # RDB2 DCD

    # 0x00 DCD header (4 bytes)
    printf "\xd2\x00\x1c\x60" | dd of="${dcd}" conv=notrunc bs=1
    # write command
    printf "\xcc\x00\x0c\x04\x40\x09\xc2\xa4\x00\x21\xc0\x00" | dd of="${dcd}" conv=notrunc bs=1 seek=4
    # write command
    printf "\xcc\x00\x0c\x01\x40\x09\xd3\x1a\x00\x00\x00\x01" | dd of="${dcd}" conv=notrunc bs=1 seek=16
elif [[ "${platform}" == "aptiv_cvc_sousa" ]]; then
    # CVC DCD

    # 0x00 DCD header (4 bytes)
    printf "\xd2\x00\x30\x60" | dd of="${dcd}" conv=notrunc bs=1
    # 0x04 DCD data (48 bytes; check s32g2 reference manual)
    # write command
    printf "\xcc\x00\x0c\x14\x40\x19\xc0\x00\x00\x00\x00\x01" | dd of="${dcd}" conv=notrunc bs=1 seek=4
    # check command
    printf "\xcf\x00\x0c\x14\x40\x19\xc0\x0c\x00\x00\x00\x01" | dd of="${dcd}" conv=notrunc bs=1 seek=16
    # write command
    printf "\xcc\x00\x0c\x14\x40\x1a\x00\x00\x00\x00\x00\x01" | dd of="${dcd}" conv=notrunc bs=1 seek=28
    # check command
    printf "\xcf\x00\x0c\x14\x40\x1a\x00\x0c\x00\x00\x00\x01" | dd of="${dcd}" conv=notrunc bs=1 seek=40
fi
