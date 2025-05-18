**简体中文** | [English](README-en.md)
 
[![Build](https://img.shields.io/badge/GitHub%20Actions-Build-181717?logo=github&logoColor=white&style=flat-square)](https://github.com/Numbersf/Action-Build/actions/workflows/Build%20SukiSU%20Ultra%20OnePlus.yml) [![Channel](https://img.shields.io/badge/Follow-Telegram-blue.svg?logo=telegram)](https://t.me/taichi91) [![OnePlus Kernel Manifest](https://img.shields.io/badge/OnePlus%20Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/OnePlusOSS/kernel_manifest)
 
# Action-Build
**```Build OnePlus SukiSU Ultra KPM Kernel```**
 
# 公告
 
配置文件中的``_x``后缀是你正在使用系统版本。``_v``是``Android15``、``_u``是``Android14``、``_t``是``Android13``、无后缀一般是一个机型出厂``Android``版本。
 
部分设备的``lz4kd``存在问题,修复中,**跑不出来请先不要启用``ZRAM算法``**,请提前备份``boot``分区!
 
``OnePlus Ace5Pro(ColorOS)OnePlus 13(ColorOS)``需要特殊处理并替换``dtbo.img``
 
记得**音量下**安装模块
 
# 更新日志
--暂时性修复`OnePlus Ace5Pro、OnePlus 13`跑不出来的问题[@reigadegr](https://github.com/reigadegr)   
--允许自定义内核后缀  <- **`beta`**  
```
1.当自定义内核后缀为空时,使用随机字符串,不再是默认的“x.xx.xxx-androidxx-8-o-g3b1e97b8b29f”
2.当自定义启用时,修改内核为“x.xx.xxx-androidxx-自定义内容”,同时也不再保留androidxx-8-o-g3b1e97b8b29f
```
--KPM 默认开启，不再可关闭  
--支持在 `ak3.zip` 中标明使用源码对应的 `Android` 版本号
```
AnyKernel3_SukiSUUltra_12866_oneplus_ace2pro_Android15_KPM_VFS.zip
```
--新增 `dir4`、`dir5` 路径用于支持 `sm8750` 和部分机型开启 ZRAM 后的新路径（比如 `ace2p`、`13T`）[@ShirkNeko](https://github.com/ShirkNeko)  
--添加 `zram` 模块的 `LZ4K` 压缩算法支持[@ShirkNeko](https://github.com/ShirkNeko)  
--移除配置文件后缀可能存在的 `_v` 或 `_u`  
--同步 `susfs` 模块上游下载频道的变化，解决无法下载的问题  
--优化 `sm8750`、`sm7675` 的 `build` 方案  
--修复版本号错误  
--新增 `dir3` 路径用于支持 `sm8475`（比如 `ace2`）  
--支持自动下载最新 `CI/Release` 的 `susfs` 模块并调用 `ksud` 安装  
--支持 `KPM`（无需任何修改复制）、`VFS HOOK`（自选是否开启）