# mods/ — 系统改动脚本

本目录存放对原厂系统的全部改动脚本，**均在设备上实测通过**。完整说明见 [docs/system-mods.md](../docs/system-mods.md)。

## pcdn/ — 清理 PCDN 挖矿组件

执行顺序**不可颠倒**，`systemcore` 是看护进程，先杀它再删文件：

```bash
adb push pcdn/block_pcdn.sh pcdn/clean_pcdn2.sh pcdn/purge_all.sh /data/local/tmp/
adb push pcdn/hosts.orig /data/local/tmp/hosts.orig      # 可选，原厂 hosts 备份

adb shell su -c "sh /data/local/tmp/block_pcdn.sh"    # [1] hosts 屏蔽 32 条 + 卸载宿主 APK
adb shell su -c "sh /data/local/tmp/clean_pcdn2.sh"   # [2] 杀载荷进程 + 删数据侧目录
adb shell su -c "sh /data/local/tmp/purge_all.sh"     # [3] 删 system 侧二进制与 rc

adb reboot                                            # 必须重启后验证
```

| 文件 | 作用 |
|---|---|
| `block_pcdn.sh` | 备份 `/system/etc/hosts`，追加 27 条 `0.0.0.0`；卸载 `com.jushi.yingyuan.h` |
| `clean_pcdn2.sh` | 追加 `meet1314.cn` 家族 5 条；清 `plugin_task_list`；杀 18 个载荷进程名；删 `/data` 侧与 `/sdcard` 侧载荷 |
| `purge_all.sh` | 三轮杀进程 + 删 `/system/bin/{systemcore,serveprocess,fhversio}`、`Bluetooth.rc`、`fhversio.rc` |
| `hosts.orig` | 原厂 `/system/etc/hosts` 原始内容（58 字节），用于还原 |

日志：`/data/local/tmp/pcdn_block.log`、`pcdn_clean2.log`

> 重启验证通过后再 `mount -o ro,remount /system` 固化只读。

## keylayout/ — 恢复遥控器电源键

```bash
adb push keylayout/fix-power-key.sh /data/local/tmp/
adb shell su -c "sh /data/local/tmp/fix-power-key.sh"
adb reboot
```

改动：`/vendor/usr/keylayout/Vendor_0416_Product_0300.kl` 第 138 行
`#key 116   POWER` → `key 116   POWER`（仅此一行，其余 427 行不变）。
脚本会自动把原文件备份到 `/data/local/tmp/Vendor_0416_Product_0300.kl.bak`，已存在则不覆盖。

## 彩蛋：遥控器开 ADB

无需脚本，直接在遥控器上按 **上 上 下 下 左 右 左 右 菜单**（KeyCode `19,19,20,20,21,22,21,22,82`）。
详见 [docs/system-mods.md#3-遥控器彩蛋开启-adb原厂内置无需改动](../docs/system-mods.md)。
