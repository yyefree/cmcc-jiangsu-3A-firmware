#!/system/bin/sh
# 恢复 CMCC_Voice_Remote (VID:PID 0416:0300) 的电源键映射
# 适用：CM311-1A / M401A（cmcc_jiangsu，S905L3A），Android 9 userdebug
# 用法：adb push fix-power-key.sh /data/local/tmp/ && adb shell sh /data/local/tmp/fix-power-key.sh
# 改完后必须 adb reboot，InputReader 只在开机时读取 keylayout

KL=/vendor/usr/keylayout/Vendor_0416_Product_0300.kl
BAK=/data/local/tmp/Vendor_0416_Product_0300.kl.bak

echo "=== [1] backup ==="
mount -o rw,remount /vendor 2>/dev/null
if [ ! -f "$BAK" ]; then
  cp -f "$KL" "$BAK" && echo "backup -> $BAK"
else
  echo "backup already exists: $BAK (keep it)"
fi
ls -l "$KL" "$BAK"

echo "=== [2] before ==="
grep -n "POWER" "$KL"

echo "=== [3] uncomment key 116 POWER ==="
if grep -q "^#key 116" "$KL"; then
  sed -i 's|^#key 116[[:space:]]*POWER|key 116   POWER|' "$KL"
  echo "patched"
else
  echo "no '#key 116 POWER' found — maybe already patched or format differs"
fi

echo "=== [4] after ==="
grep -n "POWER" "$KL"
chmod 644 "$KL"
sync

echo "=== [5] remount ro ==="
mount -o ro,remount /vendor
mount | grep " /vendor "

echo "=== DONE — run 'adb reboot' to take effect ==="
