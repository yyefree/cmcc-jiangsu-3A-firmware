---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 09f8934c4e2b37dbc283faae4b8c58a5_9d97a300e10e11f1913b525400393706
    ReservedCode1: TFHU3qYuRkRd3tQswIs3fNsHlco6J/8Z8OQBsuCdABzc0XA/pVQYDZXXn2uNFCY0He1kJGzAnQvS5br77eJHAx465/MD/PSrJHPQVTlbZc6Q9S/7no5Y1dt5NZJLQsh4xy+CB7OnOGd9mx+NqVK9kZwS8VDdg3h8321ZgVVs1+v84OL+9gdmKaLX5PQ=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 09f8934c4e2b37dbc283faae4b8c58a5_9d97a300e10e11f1913b525400393706
    ReservedCode2: TFHU3qYuRkRd3tQswIs3fNsHlco6J/8Z8OQBsuCdABzc0XA/pVQYDZXXn2uNFCY0He1kJGzAnQvS5br77eJHAx465/MD/PSrJHPQVTlbZc6Q9S/7no5Y1dt5NZJLQsh4xy+CB7OnOGd9mx+NqVK9kZwS8VDdg3h8321ZgVVs1+v84OL+9gdmKaLX5PQ=
---

# CM311-1A / M401A（江苏移动 CMCC，S905L3A）线刷包说明

本目录内的 `CM311-1A_M401A_jiangsu_A9_full_backup.img` 是由本机设备（192.168.9.130，Android 9，`V.955.05 userdebug`）通过 `dd` 逐分区备份的裸镜像，重新封装成的 **Amlogic 线刷包**（USB Burning Tool / Amlogic CustomizationTool 可识别的 `aml_upgrade_package` 格式，V2 descriptor）。

## 1. 产物清单

| 文件 | 说明 |
| --- | --- |
| `CM311-1A_M401A_jiangsu_A9_slim.img` | **精简版线刷镜像（推荐）**，1,176,237,125 字节（约 1.10 GiB），大分区 sparse |
| `CM311-1A_M401A_jiangsu_A9_full_backup.img` | 完整版线刷镜像，4,090,276,705 字节（约 3.81 GiB），全部 raw |
| `flash-package.md5` / `flash-package.sha256` | 主镜像整包校验值 |
| `flash-tools/Amlogic USB Burning Tool v2.2.0.exe` | 烧录工具（取自同型号通刷包，v2.2.0） |
| `flash-tools/311-1A短接图.jpg` | 短接点位置图（无法进入烧录模式时使用） |
| `docs/partition-table.md` | 设备 by-name 分区表与容量 |
| `scripts/restore.sh` | 分区级 dd 回写脚本（非线刷路线备用） |

## 2. 封装结构（40 个 entry）

| # | main / sub | 大小 | verify | 来源 |
| --- | --- | --- | --- | --- |
| 00 | USB / DDR | 1,387,376 | 0 | 同型号通刷包（S905L3A DDR 初始化） |
| 01 | USB / UBOOT | 1,387,376 | 0 | 同上（Burn 模式 RAM 引导） |
| 02 | PARTITION / `_aml_dtb` | 64,291 | 1 | 同上（分区表来源，与本机 by-name 完全一致） |
| 03 | VERIFY / `_aml_dtb` | 48 | 0 | `sha1sum` 文本 |
| 04 | dtb / meson1 | 64,291 | 0 | 同上 |
| 05 | conf / platform | 155 | 0 | `Platform:0x0811`、DDR 加载/运行地址 |
| 06–39 | PARTITION / VERIFY × 17 | 见下 | 1 / 0 | **本机备份的裸镜像（未压缩）** |

写入设备的 17 个分区（raw，非 sparse）：

| 分区 | 大小 | 分区 | 大小 |
| --- | --- | --- | --- |
| boot | 16 MiB | param | 16 MiB |
| cache | 1120 MiB | product | 128 MiB |
| cri_data | 8 MiB | recovery | 24 MiB |
| dtbo | 8 MiB | rsv | 16 MiB |
| ghost | 768 MiB | system | 1280 MiB |
| logo | 8 MiB | tee | 32 MiB |
| metadata | 16 MiB | vbmeta | 2 MiB |
| misc | 8 MiB | vendor | 320 MiB |
| odm | 128 MiB | | |

合计数据区 3902 MiB。完整版全部为分区原始内容（raw，`ftype=normal`）；精简版把其中 6 个大分区改为 Android sparse（`ftype=0x0FE`）：

| 分区 | raw 大小 | 精简版 payload | 压缩比 |
| --- | --- | --- | --- |
| system | 1280 MiB | 676.96 MiB | 52.9% |
| vendor | 320 MiB | 233.33 MiB | 72.9% |
| product | 128 MiB | 51.25 MiB | 40.0% |
| odm | 128 MiB | 0.46 MiB | 0.4% |
| cache | 1120 MiB | 2.96 MiB | 0.3% |
| ghost | 768 MiB | 0.00 MiB（316 B） | ≈0% |
| 其余 11 项 | 154 MiB | 154 MiB（raw） | — |

- sparse 参数：`blk_sz=4096`、version 1.0，全零块折叠为 `DONT_CARE`（每条 chunk ≤ 8192 块），非零块以 `RAW` 写入；
- 折叠仅作用于全零块，因此展开后的分区内容与原始 `dd` 镜像逐字节相同（`system` 展开后 sha1 = `429f4b1b...` 与厂商包 `verify_system` 值一致，反向验证了该结论）；
- `ftype=0x0FE` 与同型号厂商包对 sparse 分区的标注方式一致；`boot`/`recovery`/`dtbo`/`logo` 等仍保持 raw。

## 3. 刻意未包含的部分

| 项目 | 原因 |
| --- | --- |
| `data`（mmcblk0p21，约 112 GiB） | 用户数据，线刷后由系统重新初始化；保留上一台设备的 data 无意义且有隐私风险 |
| `bootloader`（4 MiB） | 含 eMMC 起始处的 `@AML` 分区头（LBA1+0x10 magic）与 u-boot，错位写入会让分区表失效；保留设备原值更安全 |
| `reserved`（64 MiB） | 工厂保留区，无 DTB 节点，工具无法按名寻址 |
| `env`（8 MiB） | u-boot 环境变量，不在 DTB `partitions` 节点内，工具无法按名寻址 |
| `mmcblk0_head32M`（32 MiB，含 `@AML` 头部 + bootloader + reserved） | 属于特权区域，整段回写会覆盖分区头，仅适用于 dd 回写路线 |
| `mmcblk0_tail8M`（8 MiB） | eMMC 尾部校验/保留区，同上 |
| `mmcblk0boot0` / `mmcblk0boot1`（各 4 MiB） | eMMC 硬件 boot 分区，需 `mmcblk0boot0` 强制 ro 解锁后才能写，线刷工具不涉及 |

> 结论：本包写入后 = 系统/数据分区与本机备份一致、分区表不变、bootloader 与 eMMC 特权区保持设备原状。`data` 会被清空（等同于恢复出厂）。

## 4. 校验记录

封装过程中已完成的校验：

1. 头部 CRC32（全文件 `[4:]`）自校验：`stored = calc = 0xdf2abb3d`，判定 OK；
2. 每个 `PARTITION` entry 与其 `VERIFY` 文本的 `sha1sum` 一一对应，写入时流式计算比对一致；
3. 成品镜像回读抽查 7 个 entry（boot / dtbo / odm / system / vbmeta / vendor / `_aml_dtb`），sha1 与源 `.img.gz` 解压流完全一致；
4. **精简版整包复验**（`validate_img.py`，逐 entry 回读）：头部 `crc_stored = 0x908ba3b8 = crc_calc`，40 个 entry 全部命中；17 个 `PARTITION` 与 `VERIFY` 文本逐一比对 `ALL OK`，其中 6 个 sparse entry 是按 chunk 展开后计算 sha1、展开长度与分区容量完全一致（1120 / 768 / 128 / 128 / 1280 / 320 MiB）。

精简版整包校验值：

```
md5     9bc2bd1158365b48e839426e8ed3fbb4
sha256  e34831927eba8827119eb39e77a3812e8fda11f9bd7a74b04d6c5ee7d166097b
size    1176237125
```

源镜像 sha1（解压后裸分区内容）：

```
boot      e91339ed947e7c7e30550fad12380fe7f0b8bf43   16777216
cache     1f09e6d67ea23e61259596b00fc9a1c449e1b35b   1174405120
cri_data  67ad3a846da4881772bdeeeaadb975050c515d33   8388608
dtbo      03edf188de484de0d9b56d2f077fb9b36ed53da5   8388608
ghost     7eb74f7d1b09557cd990232f4ad84963eb6d0226   805306368
logo      e08f77739505003391c4844339d3de2458f36924   8388608
metadata  6f73f313443d63ecd424c52236aa4cddead446af   16777216
misc      918b0269b0e1c5cd0571ab6ceaf109e2c2995a3c   8388608
odm       deca72f29e6a8051d022220be72f16dcc7196bf3   134217728
param     7af57a0041936dccf2ecfbadffa5c7404662a93f   16777216
product   a2688437bc69d120ce0664bd39af8eaa4721e7a6   134217728
recovery  5c5392cc8f8d440078cc0c511331e03d6cb79e3f   25165824
rsv       3b4417fc421cee30a9ad0fd9319220a8dae32da2   16777216
system    429f4b1b5d822aae588a078d9828c09f61c23d03   1342177280
tee       c103b85f2d6a180d4b5b25d5afec6372c3ecdce7   33554432
vbmeta    7d76d48d64d7ac5411d714a4bb83f37e3e5b8df6   2097152
vendor    67e34bcd91218ea51c199015d907f998a869ef4d   335544320
```

## 5. 烧录步骤（Windows）

1. 安装 `flash-tools/Amlogic USB Burning Tool v2.2.0.exe`（安装时勾选安装驱动）；
2. 打开工具 → `文件` → `导入烧录包` → 选择 `CM311-1A_M401A_jiangsu_A9_slim.img`（推荐；如工具对 sparse 显示异常，改用 `..._full_backup.img`）；
3. 勾选 `擦除 flash` 与 `擦除 bootloader`（**不要**勾 `擦除所有` 之外的额外选项，本包不含 bootloader，擦除 bootloader 会走工具自带的 ram 引导重写）；
4. 盒子断电 → 用双公头 USB 连接盒子靠近网口的 USB 口 → 按住复位键/短接 `flash-tools/311-1A短接图.jpg` 标注点位 → 上电；
5. 工具识别到 `Connect success` 后点击 `开始`，等待进度到 100% 与 `烧录成功`；
6. 断电重启，首次开机约 2-5 分钟（data 重建 + 分区校验）。

若工具报 `UBOOT/获取返回/DiskInitial命令出错` 等错误，多为 USB 供电或线材问题，换口/换线重试；若报分区不匹配，说明盒子并非本机同批次（分区表不同），停止烧录并回退到 `scripts/restore.sh` 的 dd 路线。

## 6. 风险提示

- 线刷会**清空 data**，设备上的应用与数据全部丢失；
- 本包使用同型号通刷包的 `USB/DDR`、`USB/UBOOT` 与 `conf/platform`（S905L3A，Platform 0x0811），DDR 颗粒与引导链与设备原生不同源；即使失败也可用同型号通刷包救回，但存在小概率需要拆机短接；
- 完整版 payload 为 raw（未压缩），整包 3.81 GiB；精简版把 6 个大分区转 sparse，整包降到 1.10 GiB，内容不变；
- 精简版的 sparse 标注（`ftype=0x0FE`）取自同型号厂商包的实际做法，但**尚未在真机上烧录验证**；首次使用建议先用完整版确认引导链可用，或准备好短接救砖。

## 7. 复现命令

封装脚本位于会话 `temp/aml/`：

```
python sparse_lib.py                           # Android sparse 编解码库（encode / decode）
python pack_aml.py <镜像目录> <模板条目目录> <输出.img> <日志>        # 完整版（全 raw）
python pack_aml_slim.py <裸镜像目录> <sparse目录> <模板目录> <输出.img> <日志>   # 精简版（大分区 sparse）
python aml_tool.py parse <输出.img>            # 结构 + CRC 自校验
python verify_pkg.py <输出.img> <报告>         # 回读抽查 sha1
python validate_img.py <输出.img>              # 精简版整包复验（含 sparse 展开比对）
```
*（内容由AI生成，仅供参考）*
