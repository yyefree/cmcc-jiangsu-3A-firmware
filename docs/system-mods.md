---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 09f8934c4e2b37dbc283faae4b8c58a5_c8929513e10211f1913b525400393706
    ReservedCode1: dFYIVEJdteclPA4+u6DiJehgQRO3CGbbaPk8PNdp6AlMRiJG63kHQ6GCszhhvbdPwARTQVRQT1Pgd2tMbi1qOauJoxzVXzK+SHC+5k2R1f7d0mL8S2qeAXwCK7X+2G3rOya/60Kyi5EIUMlntCmMhfI3lEZN0OHiHh7BoMk+oo49qeOOzp18wSUiff8=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 09f8934c4e2b37dbc283faae4b8c58a5_c8929513e10211f1913b525400393706
    ReservedCode2: dFYIVEJdteclPA4+u6DiJehgQRO3CGbbaPk8PNdp6AlMRiJG63kHQ6GCszhhvbdPwARTQVRQT1Pgd2tMbi1qOauJoxzVXzK+SHC+5k2R1f7d0mL8S2qeAXwCK7X+2G3rOya/60Kyi5EIUMlntCmMhfI3lEZN0OHiHh7BoMk+oo49qeOOzp18wSUiff8=
---

# 系统改动说明 / System Modifications

> 本文件记录对 CM311-1A / M401A（`cmcc_jiangsu`，Amlogic S905L3A，江苏移动定制）原厂 Android 9 系统所做的全部修改。
> 所有改动均在已 root（`uid=0`）的 `userdebug` 系统上以 `adb shell` 完成，**不改动 boot / 内核**，分区镜像可由本仓库 Release v1.0 原样回写还原。
> 修改日期：2026-11-10 ~ 2026-11-15

## 改动总览

| # | 改动 | 触及分区 | 可逆性 |
|---|---|---|---|
| 1 | 清理 PCDN 挖矿组件（域名屏蔽 + 载荷删除 + 宿主 APK 卸载） | `/system`、`/data` | 需回写 `system.img` + `wipe data` |
| 2 | 恢复遥控器电源键（解锁 vendor keylayout 中被注释的 `KEY_POWER`） | `/vendor` | 有 `.bak` 备份，单行还原 |
| 3 | 遥控器彩蛋开启 ADB（系统内置序列，非本次新增） | 无（原厂功能） | 无需改动 |
| 4 | 清除讯飞语音组件（可选，非必需） | `/system` | 有备份目录 |
| 5 | 替换桌面（禁用并卸载 `com.bxy.tvlauncher`，改用 `com.oversea.aslauncher`） | `/data` | 重装 APK 即可 |

---

## 1. 清理 PCDN

原厂 ROM 内置了完整的 PCDN（边缘计算 / 带宽共享）挖矿套件：由 `systemcore` 作为看护进程常驻，负责解包并拉起 `st_plugin_*` 一系列载荷，把盒子剩余带宽与存储售卖出去。清理分三步，**必须在同一轮里做完并重启验证**，否则守护进程会把载荷重新解出来。

### 1.1 域名屏蔽（`/system/etc/hosts`）

备份原文件到 `/data/local/tmp/hosts.orig`，随后追加 **32 条** `0.0.0.0` 记录，覆盖三类家族：

| 家族 | 域名 |
|---|---|
| 杭州翼兔 / bxy（`bxy123.com`、`bxy123.cn`） | `apibxy`、`apihuadun`、`apijudabao`、`apikuaiyunjing`、`apimofang`、`apiquansen`、`apishanxun`、`apishengen`、`apiszyitu`、`apixiayidai`、`hzyituapi`、`xingfuyunapi`、`apiautoscriptvideo` |
| 泰坦网络（`titannetwork.cn`、`titannet.io`） | `titannetwork.cn`、`push`、`gw`、`probe`、`probe6`、`device`、`dns2`（以上 `.titannetwork.cn`）；`titannet.io`、`test4-api`、`api`（以上 `.titannet.io`） |
| 实际载荷分发（`meet1314.cn` 等） | `meet1314.cn`、`oss.meet1314.cn`、`osshzyitu.meet1314.cn`、`ossningjiu.meet1314.cn`、`www.meet1314.cn`、`kuiniuca.com`、`walk-live.com`、`downsp.walk-live.com` |

> 关键点：只屏蔽 `bxy123` / `titannetwork` 只能挡住控制面，**真正下发插件包的是 `oss*.meet1314.cn`**，漏掉它插件仍会被重新拉回来。

### 1.2 载荷与进程清理

清空的进程名与路径：

- 进程：`systemcore`（看护者，**必须最先杀**）、`lotso` / `lotsod`、`st_plugin_supervisord`、`st_plugin_heartbeat`、`st_plugin_tunnel`、`st_plugin_resctl`、`st_plugin_minion`、`st_plugin_dispatch`、`st_plugin_syspress`、`speedtest`、`plugin_sg`、`dpand`、`taitan-agent`、`controller`、`npc`、`bfsdk3.arm7l32.bin`、`serveprocess`、`fhversio`
- `/system` 侧：`/system/bin/systemcore`、`/system/bin/serveprocess`、`/system/bin/fhversio`、`/system/etc/init/Bluetooth.rc`、`/system/etc/init/fhversio.rc`
- `/data` 侧：`/data/.lotso`、`/data/.titannet`、`/data/.ttnet`、`/data/.tt`、`/data/bfsdk`、`/data/npc`、`/data/local/systemcore`、`/data/data/com.android.system.cache`、`/data/data/com.android.systemcores`
- 存储侧：`/sdcard/pdnPlugin`、`/sdcard/Download/core-service`、`/sdcard/Download/taitan-agent.zip`

> `Bluetooth.rc` 被一并删除是因为原厂把它改成了拉起看护进程的入口，**不是** PCDN 组件本体；删掉后蓝牙功能由系统默认 service 接管，实测无影响。

### 1.3 宿主 APK 卸载

```bash
pm uninstall com.jushi.yingyuan.h                 # 聚石影院，PCDN 宿主壳
pm uninstall --user 0 com.bxy.tvlauncher          # 原厂桌面，会回写 plugin_task_list 重新激活插件
rm -rf /data/data/com.bxy.tvlauncher
sed -i '/name="plugin_task_list"/d' \
  /data/data/com.bxy.tvlauncher/shared_prefs/renmai_sp.xml   # 清掉已下发的任务清单
```

### 1.4 验证（必须重启后再验）

删除后当场观察"干净"是假象，**`adb reboot` 后重新连上再验**才是真结果：

```bash
adb connect 192.168.9.130:5555
adb shell "ps -A -o USER,PID,NAME | grep -iE 'lotso|taitan|bfsdk|npc|systemcore|serveprocess|fhversio' || echo NO_PROC"
adb shell "ls /system/bin/systemcore /system/bin/serveprocess /system/bin/fhversio 2>&1"
adb shell "find /data /sdcard -iname '*lotso*' -o -iname '*pcdn*' -o -iname '*titannet*' -o -iname '*bfsdk*' 2>/dev/null"
adb shell "mount -o ro,remount /system"
```

本次实测结果：以上进程与目录全部不存在，输出 `NO_PROC`，`hosts` 屏蔽生效（`ping` 被解析到 `0.0.0.0`）。

脚本见 [`mods/pcdn/`](../mods/pcdn/)。

---

## 2. 恢复遥控器电源键

原厂 ROM 在 vendor keylayout 里把电源键注释掉了，导致遥控器上最大的那颗键按下去毫无反应（驱动层有上报，只是没有映射）。

### 2.1 定位

```bash
# 驱动层是否有上报
adb shell "getevent -lt /dev/input/event1"     # 按键时能看到 KEY_POWER DOWN / UP
# 该遥控器实际使用的 keylayout
adb shell dumpsys input | grep -A2 CMCC_Voice_Remote
```

- 遥控器名称：`CMCC_Voice_Remote`，VID/PID `0416:0300`
- keylayout 文件：`/vendor/usr/keylayout/Vendor_0416_Product_0300.kl`

### 2.2 改动

第 138 行，取消一个 `#`：

```diff
- #key 116   POWER
+ key 116   POWER
```

完整命令：

```bash
adb shell "mount -o rw,remount /vendor"
adb shell "cp -f /vendor/usr/keylayout/Vendor_0416_Product_0300.kl \
                  /data/local/tmp/Vendor_0416_Product_0300.kl.bak"
adb shell "sed -i 's/^#key 116[[:space:]]*POWER/key 116   POWER/' \
                  /vendor/usr/keylayout/Vendor_0416_Product_0300.kl"
adb shell "chmod 644 /vendor/usr/keylayout/Vendor_0416_Product_0300.kl"
adb shell "mount -o ro,remount /vendor"
adb reboot
```

- 修改前 8985 字节 → 修改后 8984 字节，diff 结果**仅此一行**，其余 427 行完全一致
- `InputReader` 只在开机时读取 keylayout，**必须重启**才生效

### 2.3 还原

```bash
adb shell "mount -o rw,remount /vendor"
adb shell "cp -f /data/local/tmp/Vendor_0416_Product_0300.kl.bak \
                  /vendor/usr/keylayout/Vendor_0416_Product_0300.kl"
adb shell "mount -o ro,remount /vendor"
```

脚本见 [`mods/keylayout/fix-power-key.sh`](../mods/keylayout/fix-power-key.sh)。

---

## 3. 遥控器彩蛋开启 ADB（原厂内置，无需改动）

系统内置了一个隐藏的遥控器按键序列，用于在无 USB 键盘时打开 ADB。这不是本次新增的功能，只是原厂没写进任何文档。

### 3.1 按键序列

**上 → 上 → 下 → 下 → 左 → 右 → 左 → 右 → 菜单**

| 按键 | KeyCode |
|---|---|
| 上 | 19 |
| 下 | 20 |
| 左 | 21 |
| 右 | 22 |
| 菜单 | 82 |

对应内部常量字符串 **`UDUDLRLRM`**（U=Up、D=Down、L=Left、R=Right、M=Menu）。

### 3.2 实现细节（逆向结论）

- 实现类：`com.suma.oabr.OpenAdbByRemote`（SUMA 数字电视方案商代码），常量存于 `/system/framework/oat/arm/services.vdex`
- 匹配逻辑：维护一个**最近 9 次按键**的滚动缓冲区，新按键从队首压入、队尾丢弃，比较缓冲区与 `UDUDLRLRM` 是否相等
- 节奏：**无严格时间窗口**，超时不会清零，只是被后续按键按顺序顶掉；实测整段 6.6 秒按完仍可命中
- 反馈：ADB 处于关闭状态时弹出「是否开启 ADB」确认对话框；已开启时直接弹 Toast `adbd is running!`

### 3.3 使用建议

- 按序列时**中间不要误触**，误触会污染 9 位缓冲区，需要重新按满一轮
- 弹窗出现后用遥控器方向键选中"确定"并确认，之后即可 `adb connect <IP>:5555`
- 若已 root，用终端命令更省事：`setprop persist.service.adb.enable 1`（本机 `adb_enabled=1`）
- 一台上报成功的标志：`adb shell getprop persist.service.adb.enable` 返回 `1`，且 `adb devices` 能看到设备

---

## 4. 清除讯飞语音组件（可选）

原厂 `xiriservice` 会常驻监听语音唤醒，占用内存且持续联网。不刷机的场景下可移除：

- 备份目录：`/data/local/tmp/ifly_backup`
- 删除文件：
  - `/system/bin/xiriservice_All`
  - `/system/lib/libiflyblesvc_xiri_d.so`
  - `/system/lib/libxdriver_xiri_d.so`
  - `/system/etc/init/xiriservice.rc`
  - `/system/app/BtAutoConn_release_9.0_V1.0_19_20210827_chinamobile/...apk`
- 进程处理：`stop xiriservice` + `killall xiriservice_All` + `killall svciflybl`

> 副作用：语音遥控的语音键失效，遥控器其余按键正常。`xiriservice.rc` 由开机属性触发启动，删掉 rc 后不会再拉起。

---

## 5. 桌面替换

原厂 `com.bxy.tvlauncher` 是 PCDN 的宿主壳之一，会周期性回写 `plugin_task_list` 并重新激活插件，必须换掉。

```bash
pm disable-user --user 0 com.bxy.tvlauncher
pm uninstall --user 0 com.bxy.tvlauncher
rm -rf /data/data/com.bxy.tvlauncher
rm -f  /system/app/hzyitu_v1.0.78_App_store_20251022.apk
cmd package set-home-activity \
  com.oversea.aslauncher/com.oversea.aslauncher.ui.main.MainActivity
```

验证：`pm list packages | grep launcher` 中只剩 `com.oversea.aslauncher`，无 bxy 残留。

---

## 回退策略

| 改动 | 回退方式 |
|---|---|
| 全部系统改动 | 用 Release v1.0 的 `system.img.gz` / `vendor.img.gz` 按 [README 恢复章节](../README.md#恢复--救砖) 回写 |
| hosts 屏蔽 | `cp /data/local/tmp/hosts.orig /system/etc/hosts` |
| 电源键 | `cp /data/local/tmp/Vendor_0416_Product_0300.kl.bak` 回 `/vendor/usr/keylayout/` |
| 讯飞组件 | 从 `/data/local/tmp/ifly_backup` 拷回原路径并 `chmod` / `restorecon` |
| 桌面 | `adb install` 原厂 launcher APK，`cmd package set-home-activity` 指回 |
*（内容由AI生成，仅供参考）*
