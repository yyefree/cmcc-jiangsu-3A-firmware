# CMCC-Jiangsu 3A (S905L3A) 原厂分区备份 / Stock Partition Backup

> **Warning**：本仓库仅用于**个人设备救砖与固件研究**。镜像内含运营商（中国移动 CMCC 江苏）定制系统、讯飞（iFlytek）语音组件及其他第三方厂商的闭源二进制。**所有商标与版权归各自权利人所有**。请勿用于商业分发。

## 设备信息

| 项目 | 值 |
|---|---|
| 型号 (ro.product.model) | `3A` |
| 设备代号 (ro.product.device) | `cmcc_jiangsu` |
| 品牌 / 厂商 | `TV-BOX` / `PERFECT_SKY` |
| SoC 平台 (ro.board.platform) | `gxl`（Amlogic S905L3A / S905L3AB） |
| 系统版本 | Android 9 `PPR1.180610.011` |
| 完整 fingerprint | `CM311-1A/M401A/M401A:9/PPR1.180610.011/V.955.05:userdebug/test-keys` |
| 构建日期 | 2021-12-10 20:39:16 HKT |
| ABI | `armeabi-v7a`（32 位 userspace，64 位内核） |
| 构建 ID | `cmcc_jiangsu-userdebug 9 V.955.05 test-keys` |
| 构建类型 | `userdebug`（自带 root，`su` 可用） |
| eMMC 容量 | 125,057,368,064 bytes（约 116.4 GiB / 标称 128 GB） |
| 分区数量 | 21（`mmcblk0p1` ~ `mmcblk0p21`） |
| 抓取日期 | 2026-11-15 |
| 抓取方式 | `dd` 直读块设备 + `gzip -1`，逐分区 md5 双向校验 |

## 分区表

见 [docs/partition-table.md](docs/partition-table.md)。

## 下载

镜像体积超出 GitHub 仓库单文件限制，全部以 **Release 附件** 形式提供：

| 文件 | 说明 |
|---|---|
| `*.img.gz` | 各分区原始镜像的 gzip 压缩，`gzip -dc` 后与 `md5sum.txt` 中对应值一致 |
| `md5sum.txt` | 解压后镜像的 md5（与设备端 `dd \| md5sum` 结果一致） |

- 共 **24 个镜像**：20 个 `by-name` 分区（除 `data`）+ `mmcblk0boot0/1` + `mmcblk0` 头 32 MiB / 尾 8 MiB
- 解压后合计 **4,217,372,672 bytes**，gz 合计 **587,526,023 bytes**

对应 Release：见仓库右侧 Releases 页面。

## 恢复 / 救砖

> **高风险**：回写会覆盖目标分区，操作失误可导致设备无法开机。请确认设备型号与本仓库一致。

### 前置条件

- 设备已 root，`adb shell` 中 `id` 返回 `uid=0`
- 已将所需 `.img.gz` 与 `restore.sh` 推入设备，例如 `/data/local/tmp/fw/`

### 步骤

```bash
# 1. 推送镜像与脚本
adb push *.img.gz /data/local/tmp/fw/
adb push scripts/restore.sh /data/local/tmp/

# 2. 校验（必须全部 OK 后再继续）
adb shell "cd /data/local/tmp/fw && for f in *.img.gz; do gzip -dc $f | md5sum; done"

# 3. 回写（只回写需要恢复的分区，例如仅 system + boot）
adb shell sh /data/local/tmp/restore.sh /data/local/tmp/fw system boot

# 4. 重启
adb shell sync && adb reboot
```

### 单分区手动回写

```bash
adb shell "gzip -dc /data/local/tmp/fw/system.img.gz | dd of=/dev/block/system bs=1048576"
adb shell "gzip -dc /data/local/tmp/fw/boot.img.gz   | dd of=/dev/block/boot   bs=1048576"
adb shell sync
```

## 全盘备份（自行复现）

`scripts/dump.sh` 即本次抓取所用脚本，可对同型号设备重新生成完整备份：

```bash
adb push scripts/dump.sh /data/local/tmp/
adb shell "nohup sh /data/local/tmp/dump.sh >/dev/null 2>&1 &"
adb shell "tail -f /data/local/tmp/fw/job.log"   # 观察进度
```

## 已知门槛

- **不是 Amlogic 线刷包**。本仓库是分区级裸镜像，不能直接喂给 `USB Burning Tool`；要线刷需用 `aml_image_packer` / Amlogic CustomizationTool 按分区表重新封装。
- `data`（`mmcblk0p21`）不包含在备份中，回写后需 `wipe data`。
- `cache`（`mmcblk0p3`）为可重建分区，可选恢复。
- `mmcblk0_head32M.img.gz` / `mmcblk0_tail8M.img.gz` 为 GPT 主备表，仅在分区表损坏时使用。

## 校验

```bash
sha256sum -c SHA256SUMS 2>/dev/null || md5sum -c md5sum.txt
```
