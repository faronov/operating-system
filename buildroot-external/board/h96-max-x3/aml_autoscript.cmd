# Amlogic vendor U-Boot boot script for H96 Max X3 (S905X3)
#
# This script runs when Android U-Boot processes 'reboot update':
#   switch_bootmode -> update -> recovery_from_sdcard -> autoscr aml_autoscript
#
# The vendor U-Boot (2015.01-based) only supports:
#   fatload, bootm, autoscr, mmc read/write, setenv, echo, fdt
# It does NOT have: ext4load, load, booti, part start, source
#
# To boot from SD card:
#   1. Write HAOS image to SD card
#   2. Insert SD into H96 Max X3 running Android
#   3. Enable ADB over network (Settings -> About -> tap Build 7x -> Developer Options -> ADB)
#   4. Run: adb connect <ip>:5555 && adb shell reboot update

echo "=== HAOS Boot for H96 Max X3 ==="

# SD card is mmc 1 in this U-Boot (mmc 0 = eMMC)
setenv devnum 1

# Memory addresses matching this U-Boot
setenv kernel_addr_r 0x1080000
setenv fdt_addr_r 0x1000000
setenv ramdisk_addr_r 0x3080000

# Load device tree - try mmc 1 first, then mmc 0
echo "Loading DTB..."
if fatload mmc 1:1 ${fdt_addr_r} meson-sm1-h96-max.dtb; then
    setenv devnum 1
    echo "DTB loaded from mmc 1"
elif fatload mmc 0:1 ${fdt_addr_r} meson-sm1-h96-max.dtb; then
    setenv devnum 0
    echo "DTB loaded from mmc 0"
else
    echo "DTB load FAILED"
fi
fdt addr ${fdt_addr_r}

# Load uImage (gzip-compressed kernel in legacy format for bootm)
echo "Loading uImage kernel..."
if fatload mmc ${devnum}:1 ${ramdisk_addr_r} uImage; then
    echo "uImage loaded OK"
else
    echo "uImage load FAILED - no boot"
fi

# Boot arguments for HAOS slot A
# TODO: Implement A/B slot selection by reading BootInfo from partition 9
setenv bootargs "root=PARTUUID=48617373-06 ro rootwait zram.enabled=1 zram.num_devices=3 clk_ignore_unused console=ttyAML0,115200 console=tty0 systemd.machine_id= systemd.condition-first-boot=true rauc.slot=A"

echo "Booting HAOS..."
bootm ${ramdisk_addr_r} - ${fdt_addr_r}

echo "=== Boot FAILED - falling through to Android ==="
