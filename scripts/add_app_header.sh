#!/bin/bash
# shellcheck disable=2059,2155

set -eE -o pipefail

# Application boot code image
#
# For nonsecure boot configuration, the application image pointed to by IVT should comply with the
# below structure.
#
# Address | Size        | Name Comment
# Offset  | (in Bytes)  |
# --------|-------------|---------------------------------------------------------------------------
# 0x0     |  4          | Image header      | Header to signify start of application image. (fixed)
# 0x04    |  4          | RAM Start pointer | Pointer to the RAM location BootROM uses to copy the
#         |             |                   | code.
# 0x08    |  4          | RAM entry pointer | Pointer to start of code execution. This pointer
#         |             |                   | should be within the section of SRAM where the
#         |             |                   | application image is downloaded.
# 0x0C    |  4          | Code length       | Length of code section of the image.
# 0x10    | 48          | Reserved          |
# 0x40    | Code_length | Code              | Code can be any size up to the max size of System SRAM.

trap "cleanup; exit 2" ERR

declare -r work_dir="$(mktemp -d -p /tmp)"
declare app_in=""
declare app_out=""
declare header_export=false
declare ram_load=""
declare ram_entry=""

cleanup() {
    set +eE
    rm -rf "${work_dir:?}"
}

# brief:
#   prepare a format string for writing binary data with printf
#
# params:
#   1: num - the number to include in the string
#   2: base - numerical base of 'num', 'hex' (default) or 'dec'
#   3: endian - endianness of 'num'
fmt_str() {
    num=""
    base="${2:-hex}"
    endian="${3:-le}"

    if [[ "${base}" == "hex" ]]; then
        num="${1}"
    else
        num="$(printf "%.0d%.8x" 0000000 "${1}")"
    fi

    if [[ "${endian}" == "be" ]]; then
        echo -n "\\x${num:0:2}\\x${num:2:2}\\x${num:4:2}\\x${num:6:2}"
    else
        echo -n "\\x${num:6:2}\\x${num:4:2}\\x${num:2:2}\\x${num:0:2}"
    fi
}

while getopts "e:di:l:o:x" opt; do
    case "${opt}" in
        e)
            # RAM entry address
            ram_entry="${OPTARG}"
            ;;
        d)
            # Provide header as dedicated binary
            header_export=true
            ;;
        i)
            # Input application binary
            app_in="${OPTARG}"
            ;;
        l)
            # RAM load address
            ram_load="${OPTARG}"
            ;;
        o)
            # Output application binary
            app_out="${OPTARG}"
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

if [[ -z "${app_in}" || -z "${app_out}" ]]; then
    cleanup
    exit 1
fi
if [[ ${#ram_load} -ne 8 ]]; then
    exit 1
fi
if [[ ${#ram_load} -ne 8 ]]; then
    exit 1
fi

# Application boot image structure
# --------------------------------
#
# Address   | Size          | Name
# Offset    | in bytes      |
# ----------|---------------|---------------------------------------
# 0x00      | 4             | Image header (0xd5000060, big endian)
# 0x04      | 4             | RAM start pointer
# 0x08      | 4             | RAM entry pointer
# 0x0c      | 4             | Code length
# 0x10      | 48            | Reserved
# 0x40      | code length   | Code

declare -r app_size="$(du -Lb "${app_in}" | awk '{print $1}')"
declare -r app_header="${work_dir}/$(basename "${app_in}").header"

# prepare empty app header binary
dd if=/dev/zero of="${app_header}" bs=64 count=1

# 0x00 image header (4 bytes)
# printf "\xd5\x00\x00\x60" | dd conv=notrunc of="${app_header}"
printf "$(fmt_str 'd5000060' 'hex' 'be')" | dd conv=notrunc of="${app_header}"
# 0x04 RAM start pointer (4 bytes)
# printf "$(bswap32 "${ram_load}" "hex")" | dd conv=notrunc of="${app_header}" seek=4 bs=1
printf "$(fmt_str "${ram_load}")" | dd conv=notrunc of="${app_header}" seek=4 bs=1
# 0x08 RAM entry pointer (4 bytes)
# printf "$(bswap32 "${ram_entry}" "hex")" | dd conv=notrunc of="${app_header}" seek=8 bs=1
printf "$(fmt_str "${ram_entry}")" | dd conv=notrunc of="${app_header}" seek=8 bs=1
# 0x0c code size (4 bytes)
# printf "$(bswap32 "${app_size}")" | dd conv=notrunc of="${app_header}" seek=12 bs=1
printf "$(fmt_str "${app_size}" 'dec')" | dd conv=notrunc of="${app_header}" seek=12 bs=1

cat "${app_header}" "${app_in}" > "${work_dir}/app.tmp"
mv "${work_dir}/app.tmp" "${app_out}"

if [[ "${header_export}" == true ]]; then
    mv "${app_header}" "$(dirname "${app_out}")"
fi

cleanup
