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

## 系统改动

本仓库除原厂镜像外，还记录了在本机上完成的可用性改造 —— 既给出脚本，也给出**验证方式与回退路径**。完整说明见 **[docs/system-mods.md](docs/system-mods.md)**，脚本见 [`mods/`](mods/)。

| 改动 | 一句话说明 | 触及分区 | 脚本 / 操作 |
|---|---|---|---|
| **清理 PCDN** | 原厂内置 `systemcore` 看护进程不断拉起 `st_plugin_*` 载荷，将盒子带宽与存储用于 PCDN 挖矿。通过 hosts 屏蔽 32 个控制/分发域名 + 删除 `/system` 与 `/data` 双侧载荷 + 卸载宿主 APK 彻底清除，**重启后复验**无残留 | `/system`、`/data` | [`mods/pcdn/`](mods/pcdn/) |
| **恢复遥控器电源键** | 原厂在 `Vendor_0416_Product_0300.kl` 第 138 行把 `key 116 POWER` 注释掉了，导致遥控器电源键无响应。取消注释后重启生效 | `/vendor` | [`mods/keylayout/fix-power-key.sh`](mods/keylayout/fix-power-key.sh) |
| **遥控器彩蛋开 ADB** | 系统内置序列 **上→上→下→下→左→右→左→右→菜单**（`UDUDLRLRM`，KeyCode `19,19,20,20,21,22,21,22,82`），可在无 USB 键盘时打开 ADB。9 键滚动缓冲区匹配，无时间窗限制 | 无（原厂功能） | 遥控器直接按 |
| 清除讯飞语音组件 | 移除常驻的 `xiriservice`，降低内存与联网占用（副作用：语音键失效） | `/system` | 见 docs |
| 替换原厂桌面 | `com.bxy.tvlauncher` 会回写 `plugin_task_list` 复活 PCDN 插件，改用 `com.oversea.aslauncher` | `/data` | 见 docs |

> 电源键与彩蛋可以同时使用：电源键短按待机、长按电源菜单；ADB 打开后 `adb connect <IP>:5555` 即可接管。

## 下载

镜像体积超出 GitHub 仓库单文件限制，全部以 **Release 附件** 形式提供：

| 文件 | 说明 |
|---|---|
| `*.img.gz` | 各分区原始镜像的 gzip 压缩，`gzip -dc` 后与 `md5sum.txt` 中对应值一致 |
| `md5sum.txt` | 解压后镜像的 md5（与设备端 `dd \| md5sum` 结果一致） |

- 共 **24 个镜像**：20 个 `by-name` 分区（除 `data`）+ `mmcblk0boot0/1` + `mmcblk0` 头 32 MiB / 尾 8 MiB
- 解压后合计 **4,217,372,672 bytes**，gz 合计 **587,526,023 bytes**

对应 Release：**[v1.0 — CM311-1A / M401A 原厂分区备份](https://github.com/yyefree/cmcc-jiangsu-3A-firmware/releases/tag/v1.0)**（24 个 `img.gz` + `md5sum.txt`）

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
