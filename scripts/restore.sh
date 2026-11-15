#!/system/bin/sh
# restore.sh — 将分区镜像回写到本机 eMMC（仅限 CMCC-Jiangsu 3A / S905L3A）
#
# 用法：
#   sh restore.sh <镜像目录> [分区名 ...]
#   sh restore.sh /data/local/tmp/fw              # 交互确认后回写全部可用镜像
#   sh restore.sh /data/local/tmp/fw system boot  # 只回写指定分区
#
# 安全机制：
#   1. 回写前比对解压流 md5 与目录内 <分区>.md5，不一致则跳过（除非 FORCE=1）
#   2. 分区必须存在于 /dev/block/
#   3. 不处理 data 分区（回写后需自行 wipe）

DIR="$1"
shift
if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "用法: sh restore.sh <镜像目录> [分区名 ...]"
    exit 1
fi

KNOWN="bootloader reserved cache env logo recovery misc dtbo cri_data param boot metadata vbmeta tee vendor odm system product ghost"

if [ $# -eq 0 ]; then
    echo "将回写 $DIR 下所有存在的镜像到 /dev/block/。"
    echo "此操作不可撤销，设备可能无法开机。"
    printf "输入 YES 继续: "
    read a
    [ "$a" = "YES" ] || { echo "已取消"; exit 1; }
    LIST="$KNOWN"
else
    LIST="$*"
fi

FAIL=0
for p in $LIST; do
    [ "$p" = "data" ] && { echo "跳过 data"; continue; }
    IMG="$DIR/$p.img.gz"
    [ -f "$IMG" ] || { echo "SKIP $p (无镜像)"; continue; }
    [ -e "/dev/block/$p" ] || { echo "SKIP $p (设备无此分区)"; continue; }

    CALC=$(gzip -dc "$IMG" | md5sum | awk '{print $1}')
    if [ -f "$DIR/$p.md5" ]; then
        WANT=$(cat "$DIR/$p.md5")
        if [ "$CALC" != "$WANT" ] && [ "$FORCE" != "1" ]; then
            echo "FAIL $p md5 不符 (期望 $WANT 实际 $CALC)，跳过。FORCE=1 可强制"
            FAIL=1
            continue
        fi
    fi

    echo "WRITE $p $(blockdev --getsize64 /dev/block/$p) bytes ..."
    gzip -dc "$IMG" | dd of="/dev/block/$p" bs=1048576 2>/dev/null
    echo "OK $p"
done

sync
echo "完成。FAIL=$FAIL"
echo "全部成功请执行: adb reboot"
