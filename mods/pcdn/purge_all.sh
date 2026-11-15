#!/system/bin/sh
mount -o rw,remount /system 2>/dev/null
echo "=== [1] 杀进程（3 轮，先杀看护者 systemcore）==="
i=0
while [ $i -lt 3 ]; do
  for p in $(ps -A -o PID,NAME 2>/dev/null | grep -iE "systemcore|lotso|serveprocess|fhversio|/data/npc" | grep -v grep | cut -d" " -f1); do
    kill -9 "$p" 2>/dev/null && echo "killed $p"
  done
  i=$((i+1))
  sleep 2
done
echo "=== [2] 删系统侧二进制与 rc ==="
for f in /system/bin/systemcore /system/bin/serveprocess /system/bin/fhversio /system/etc/init/Bluetooth.rc /system/etc/init/fhversio.rc; do
  rm -f "$f" && echo "rm $f"
done
echo "=== [3] 删数据侧 ==="
for d in /data/local/systemcore /data/.lotso /data/npc /data/media/0/pdnPlugin /data/data/com.android.systemcores; do
  rm -rf "$d" && echo "rm -rf $d"
done
sync
echo "=== [4] 立即验证 ==="
echo "--- 进程 ---"
ps -A -o PID,PPID,USER,NAME 2>/dev/null | grep -iE "systemcore|lotso|npc|serveprocess|fhversio" | grep -v grep || echo "NO_PROC"
echo "--- 文件 ---"
ls -l /system/bin/systemcore /system/bin/serveprocess /system/bin/fhversio /system/etc/init/Bluetooth.rc /system/etc/init/fhversio.rc 2>&1
echo "--- 目录 ---"
ls -ld /data/.lotso /data/npc /data/media/0/pdnPlugin /data/data/com.android.systemcores /data/local/systemcore 2>&1
echo "=== DONE ==="
