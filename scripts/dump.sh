#!/system/bin/sh
# dump.sh — CMCC-Jiangsu 3A (S905L3A) 分区级备份脚本
# 需 root（adb shell 下 id 应为 uid=0）
#
# 用法：
#   adb push dump.sh /data/local/tmp/
#   adb shell "nohup sh /data/local/tmp/dump.sh >/dev/null 2>&1 &"
#   adb shell "cat /data/local/tmp/fw/job.log"
#
# 输出：/data/local/tmp/fw/<分区>.img.gz + <分区>.md5（解压后镜像的 md5）
# 不含 data 分区（体积大且属用户数据）

D=/data/local/tmp/fw
mkdir -p $D

# 注意：toybox dd 不支持 bs=1M，必须写 bs=1048576
PARTS="system vendor product odm ghost reserved bootloader boot dtbo logo misc env recovery vbmeta param tee cri_data metadata cache"

for p in $PARTS; do
  [ -e /dev/block/$p ] || { echo "SKIP $p (不存在)" >> $D/job.log; continue; }
  echo "START $p $(date +%H:%M:%S)" >> $D/job.log
  gzip -1 -c /dev/block/$p > $D/$p.img.gz 2>/dev/null
  dd if=/dev/block/$p bs=1048576 2>/dev/null | md5sum | awk '{print $1}' > $D/$p.md5
  echo "DONE $p $(ls -l $D/$p.img.gz | awk '{print $5}') $(date +%H:%M:%S)" >> $D/job.log
done

# eMMC boot 分区
for b in mmcblk0boot0 mmcblk0boot1; do
  gzip -1 -c /dev/block/$b > $D/$b.img.gz
  dd if=/dev/block/$b bs=4096 2>/dev/null | md5sum | awk '{print $1}' > $D/$b.md5
  echo "DONE $b" >> $D/job.log
done

# GPT 主表（前 32MB，含 bootloader 区）与备份表（末 8MB）
TOTAL=$(blockdev --getsize64 /dev/block/mmcblk0)
HEADCNT=8192
TAILCNT=2048
SKIP=$(( TOTAL / 4096 - TAILCNT ))

dd if=/dev/block/mmcblk0 bs=4096 count=$HEADCNT 2>/dev/null | gzip -1 > $D/mmcblk0_head32M.img.gz
dd if=/dev/block/mmcblk0 bs=4096 count=$HEADCNT 2>/dev/null | md5sum | awk '{print $1}' > $D/mmcblk0_head32M.md5

dd if=/dev/block/mmcblk0 bs=4096 skip=$SKIP count=$TAILCNT 2>/dev/null | gzip -1 > $D/mmcblk0_tail8M.img.gz
dd if=/dev/block/mmcblk0 bs=4096 skip=$SKIP count=$TAILCNT 2>/dev/null | md5sum | awk '{print $1}' > $D/mmcblk0_tail8M.md5

cat /proc/partitions > $D/proc_partitions.txt
echo DONE > $D/.done
echo "ALL DONE $(date +%H:%M:%S)" >> $D/job.log
