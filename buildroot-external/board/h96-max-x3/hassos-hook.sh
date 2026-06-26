#!/bin/bash
# shellcheck disable=SC2155

function haos_pre_image() {
    local BOOT_DATA="$(path_boot_dir)"

    cp "${BINARIES_DIR}/boot.scr" "${BOOT_DATA}/boot.scr"
    cp "${BINARIES_DIR}/meson-sm1-h96-max.dtb" "${BOOT_DATA}/meson-sm1-h96-max.dtb"

    mkdir -p "${BOOT_DATA}/overlays"
    cp "${BINARIES_DIR}"/*.dtbo "${BOOT_DATA}/overlays/" 2>/dev/null || true
    cp "${BOARD_DIR}/boot-env.txt" "${BOOT_DATA}/haos-config.txt"
    cp "${BOARD_DIR}/cmdline.txt" "${BOOT_DATA}/cmdline.txt"

    # Vendor U-Boot (2015.01) on eMMC only supports fatload + bootm.
    # Create uImage for bootm (needed when booting via adb reboot update).
    gzip -k -9 "${BINARIES_DIR}/Image"
    mkimage -A arm64 -O linux -T kernel -C gzip \
        -a 0x1080000 -e 0x1080000 \
        -d "${BINARIES_DIR}/Image.gz" "${BOOT_DATA}/uImage"
    rm -f "${BINARIES_DIR}/Image.gz"

    # Compile aml_autoscript for vendor U-Boot SD boot via 'reboot update'
    mkimage -A arm64 -O linux -T script -C none \
        -d "${BOARD_DIR}/aml_autoscript.cmd" "${BOOT_DATA}/aml_autoscript"
    cp "${BOOT_DATA}/aml_autoscript" "${BOOT_DATA}/s905_autoscript"
}


function haos_post_image() {
    convert_disk_image_xz
}
