#!/system/bin/sh
LOG=/data/local/tmp/pcdn_clean2.log
exec >> $LOG 2>&1
echo "=================== START $(date '+%Y-%m-%d %H:%M:%S') ==================="

echo "--- [1] block real payload host: meet1314.cn ---"
mount -o rw,remount /system
grep -q "meet1314.cn" /system/etc/hosts || cat >> /system/etc/hosts <<'EOF'
0.0.0.0 meet1314.cn
0.0.0.0 oss.meet1314.cn
0.0.0.0 osshzyitu.meet1314.cn
0.0.0.0 ossningjiu.meet1314.cn
0.0.0.0 www.meet1314.cn
EOF
sync
echo "hosts meet1314 count: $(grep -c meet1314 /system/etc/hosts)"
ping -c 1 -W 2 osshzyitu.meet1314.cn 2>&1 | head -2

echo "--- [2] clear cached plugin task list ---"
SP=/data/data/com.bxy.tvlauncher/shared_prefs/renmai_sp.xml
cp -f $SP /data/local/tmp/renmai_sp.xml.bak
sed -i '/name="plugin_task_list"/d' $SP
echo "after edit plugin_task_list count: $(grep -c plugin_task_list $SP)"

echo "--- [3] force-stop launcher so it cannot rewrite prefs ---"
am force-stop com.bxy.tvlauncher
sleep 2
echo "after force-stop plugin_task_list count: $(grep -c plugin_task_list $SP)"

echo "--- [4] bring desktop back ---"
HOME_ACT=$(cmd package resolve-activity --brief -c android.intent.category.HOME 2>/dev/null | tail -1)
echo "home activity: $HOME_ACT"
am start -n "$HOME_ACT" 2>&1 | head -3

echo "--- [5] kill payloads ---"
for p in $(ps -A -o PID | tail -n +2); do
  E=$(readlink /proc/$p/exe 2>/dev/null)
  case "$E" in
    */data/.lotso*|*/data/.titannet*|*/data/bfsdk*|*/data/npc*|*/data/local/systemcore*|*/system/bin/systemcore*)
      echo "kill -9 $p ($E)"; kill -9 $p 2>/dev/null;;
  esac
done
for n in lotso lotsod st_plugin_supervisord st_plugin_heartbeat st_plugin_tunnel st_plugin_resctl st_plugin_minion st_plugin_dispatch st_plugin_syspress speedtest plugin_sg dpand taitan-agent controller npc bfsdk3.arm7l32.bin systemcore; do
  pkill -9 -f "$n" 2>/dev/null && echo "pkill $n"
done

echo "--- [6] delete payloads ---"
rm -rf /data/.lotso /data/.titannet /data/bfsdk /data/npc
rm -rf /sdcard/pdnPlugin /sdcard/Download/core-service /sdcard/Download/taitan-agent.zip
rm -f /data/local/systemcore /system/bin/systemcore
rm -rf /data/.ttnet /data/.tt /data/data/com.android.system.cache /data/data/com.android.systemcores
sync

echo "--- [7] remount ro & verify ---"
mount -o ro,remount /system
for d in /data/.lotso /data/.titannet /data/bfsdk /data/npc /sdcard/pdnPlugin /data/local/systemcore /system/bin/systemcore; do
  [ -e "$d" ] && echo "STILL $d" || echo "GONE $d"
done
ps -A -o USER,PID,NAME | grep -iE "lotso|taitan|bfsdk|np[c]$|systemcore" || echo "NO_PROC"
ps -A -o PID,NAME | grep bxy
echo "=================== END $(date '+%Y-%m-%d %H:%M:%S') ==================="
