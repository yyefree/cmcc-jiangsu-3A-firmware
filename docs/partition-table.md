# 分区表（CMCC-Jiangsu 3A / S905L3A）

## 概览

- 设备节点：`/dev/block/platform/ffe07000.emmc/by-name/`
- 全部 21 个分区位于 `mmcblk0`，`mmcblk0` 总容量 125,057,368,064 bytes
- 另有 eMMC boot 分区 `mmcblk0boot0` / `mmcblk0boot1`（各 4 MiB）
- **本机不使用标准 GPT**：`mmcblk0` 头部为 Amlogic 自定义 `@AML` 头（magic 在 LBA1 + 0x10），未检出 `EFI PART`。分区名与边界由 bootloader / DT 给出，因此**不能**用普通 `sgdisk` 之类工具直接改写此盘的分区表。
- `mmcblk0_head32M` / `mmcblk0_tail8M` 是头尾原始数据（含 Amlogic 头与分区信息区），仅在分区信息损坏时回写。

## by-name 映射

| 序号 | 分区名 | 设备节点 | 主次号 | 大小 |
|---|---|---|---:|---:|
| p1 | bootloader | /dev/block/bootloader | 179,1 | 4 MiB |
| p2 | reserved | /dev/block/reserved | 179,2 | 64 MiB |
| p3 | cache | /dev/block/cache | 179,3 | 1120 MiB |
| p4 | env | /dev/block/env | 179,4 | 8 MiB |
| p5 | logo | /dev/block/logo | 179,5 | 8 MiB |
| p6 | recovery | /dev/block/recovery | 179,6 | 24 MiB |
| p7 | misc | /dev/block/misc | 179,7 | 8 MiB |
| p8 | dtbo | /dev/block/dtbo | 179,8 | 8 MiB |
| p9 | cri_data | /dev/block/cri_data | 179,9 | 8 MiB |
| p10 | param | /dev/block/param | 179,10 | 16 MiB |
| p11 | boot | /dev/block/boot | 179,11 | 16 MiB |
| p12 | rsv | /dev/block/rsv | 179,12 | 16 MiB |
| p13 | metadata | /dev/block/metadata | 179,13 | 16 MiB |
| p14 | vbmeta | /dev/block/vbmeta | 179,14 | 2 MiB |
| p15 | tee | /dev/block/tee | 179,15 | 32 MiB |
| p16 | vendor | /dev/block/vendor | 179,16 | 320 MiB |
| p17 | odm | /dev/block/odm | 179,17 | 128 MiB |
| p18 | system | /dev/block/system | 179,18 | 1280 MiB |
| p19 | product | /dev/block/product | 179,19 | 128 MiB |
| p20 | ghost | /dev/block/ghost | 179,20 | 768 MiB |
| p21 | data | /dev/block/data | 179,21 | 112.4 GiB（未备份） |
| — | boot0 | /dev/block/mmcblk0boot0 | 179,32 | 4 MiB |
| — | boot1 | /dev/block/mmcblk0boot1 | 179,64 | 4 MiB |
| — | rpmb | /dev/block/mmcblk0rpmb | 179,96 | 4 MiB（未备份） |

## 镜像清单

| 镜像 | 原始大小 | gz 大小 | md5 (解压后) |
|---|---:|---:|---|
| `boot.img.gz` | 16,777,216 | 11,534,267 | `26a08c59a95ba706abdba953eb9a3556` |
| `bootloader.img.gz` | 4,194,304 | 893,425 | `79b6f22cdf7d147ff5a364801e588869` |
| `cache.img.gz` | 1,174,405,120 | 5,201,453 | `34a2bc4fcab0b2ca919da5491ffb19af` |
| `cri_data.img.gz` | 8,388,608 | 36,656 | `72252dd3882a9b6c95d8022b9121b565` |
| `dtbo.img.gz` | 8,388,608 | 36,844 | `40e234792c60859200f85ac1b3e72c6e` |
| `env.img.gz` | 8,388,608 | 39,662 | `c535320b5eee7f4824ea41e79a85e0f4` |
| `ghost.img.gz` | 805,306,368 | 3,514,111 | `72b74a1ecec4fd35ec0c7278202130a8` |
| `logo.img.gz` | 8,388,608 | 3,863,129 | `cb68fc14508645d299c01a8dc46477d9` |
| `metadata.img.gz` | 16,777,216 | 74,550 | `3606651e4134304f40e706038cbe8a5e` |
| `misc.img.gz` | 8,388,608 | 36,659 | `fab08f1ba2d7a12b2787583dce52c5c8` |
| `mmcblk0_head32M.img.gz` | 33,554,432 | 1,021,544 | `be27c59b8e8de47e4856082f1990c444` |
| `mmcblk0_tail8M.img.gz` | 8,388,608 | 36,626 | `96995b58d4cbf6aaa9041b4f00c7f6ae` |
| `mmcblk0boot0.img.gz` | 4,194,304 | 893,435 | `e803bb515d589674a315255806ef0fed` |
| `mmcblk0boot1.img.gz` | 4,194,304 | 893,435 | `e803bb515d589674a315255806ef0fed` |
| `odm.img.gz` | 134,217,728 | 734,022 | `6777bf1c65b673b841655d4dec7df58b` |
| `param.img.gz` | 16,777,216 | 252,825 | `219d308029f7647588b004897285f0eb` |
| `product.img.gz` | 134,217,728 | 29,977,879 | `c1cf655cf2a95c6ba915f6f6ce79dde7` |
| `recovery.img.gz` | 25,165,824 | 17,315,729 | `ba7a2f5cdad21c07ad5ab4942e54a752` |
| `reserved.img.gz` | 67,108,864 | 950,624 | `9d0967341ed778cd966deebc21a3e089` |
| `rsv.img.gz` | 16,777,216 | 73,231 | `2c7ab85a893283e98c931e9511add182` |
| `system.img.gz` | 1,342,177,280 | 390,877,701 | `9b3ff106b354aca2ada8686ac04896d3` |
| `tee.img.gz` | 33,554,432 | 147,028 | `99f11d70a0f643a1814f040befe8b88d` |
| `vbmeta.img.gz` | 2,097,152 | 9,180 | `b2d1236c286a3c0704224fe4105eca49` |
| `vendor.img.gz` | 335,544,320 | 119,112,008 | `1a708b0a147b6969f14e1442c8965b3b` |
| **合计（不含 data）** | **4,217,372,672** | **587,526,023** | |

## 说明

- 所有 md5 均为**解压后镜像**的 md5，且与设备端 `dd if=/dev/block/<分区> | md5sum` 的结果逐字节比对一致。
- `mmcblk0boot0` 与 `mmcblk0boot1` md5 相同，内容为清除态（全 `0x00`），属正常。
- `system` / `vendor` / `odm` / `product` 为 ext4 分区原始镜像，可直接 loop 挂载查看：
  ```bash
  gzip -dc system.img.gz > system.img
  sudo mount -o loop,ro system.img /mnt
  ```
- `cache` / `ghost` 压缩率极高（多为空白区），但原始大小仍需保证回写分区足够大。
- `data` 未备份（112.4 GiB，且属用户数据）；回写后如需恢复出厂需自行 `mkfs.ext4` 或进 recovery wipe。
