#!/system/bin/sh
LOG=/data/local/tmp/pcdn_block.log
exec >> $LOG 2>&1
echo "=================== START $(date '+%Y-%m-%d %H:%M:%S') ==================="

echo "--- [1] backup hosts ---"
mount -o rw,remount /system
cp -f /system/etc/hosts /data/local/tmp/hosts.orig
cat /system/etc/hosts

echo "--- [2] append pcdn block entries ---"
cat >> /system/etc/hosts <<'EOF'
# ==== PCDN blocklist added 2026-11-10 ====
0.0.0.0 apibxy.bxy123.com
0.0.0.0 apihuadun.bxy123.com
0.0.0.0 apijudabao.bxy123.com
0.0.0.0 apikuaiyunjing.bxy123.com
0.0.0.0 apimofang.bxy123.com
0.0.0.0 apiquansen.bxy123.com
0.0.0.0 apishanxun.bxy123.com
0.0.0.0 apishengen.bxy123.com
0.0.0.0 apiszyitu.bxy123.com
0.0.0.0 apixiayidai.bxy123.com
0.0.0.0 hzyituapi.bxy123.com
0.0.0.0 xingfuyunapi.bxy123.com
0.0.0.0 apiautoscriptvideo.bxy123.cn
0.0.0.0 titannetwork.cn
0.0.0.0 push.titannetwork.cn
0.0.0.0 gw.titannetwork.cn
0.0.0.0 probe.titannetwork.cn
0.0.0.0 probe6.titannetwork.cn
0.0.0.0 device.titannetwork.cn
0.0.0.0 dns2.titannetwork.cn
0.0.0.0 titannet.io
0.0.0.0 test4-api.titannet.io
0.0.0.0 api.titannet.io
0.0.0.0 kuiniuca.com
0.0.0.0 walk-live.com
0.0.0.0 downsp.walk-live.com
EOF
sync
echo "--- hosts now ---"
cat /system/etc/hosts

echo "--- [3] uninstall com.jushi.yingyuan.h ---"
pm uninstall com.jushi.yingyuan.h
rm -rf /data/data/com.jushi.yingyuan.h
ls -d /data/app/*jushi* 2>&1

echo "--- [4] remount ro ---"
mount -o ro,remount /system
mount | grep " /system "

echo "--- [5] verify dns block ---"
ping -c 1 -W 2 push.titannetwork.cn 2>&1 | head -3
ping -c 1 -W 2 apiszyitu.bxy123.com 2>&1 | head -3

echo "=================== END $(date '+%Y-%m-%d %H:%M:%S') ==================="
