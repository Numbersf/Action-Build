**Enlish** | [简体中文](README.md)

[![Build](https://img.shields.io/badge/GitHub%20Actions-Build-181717?logo=github&logoColor=white&style=flat-square)](https://github.com/Numbersf/Action-Build/actions/workflows/Build%20SukiSU%20Ultra%20OnePlus.yml) [![Channel](https://img.shields.io/badge/Follow-Telegram-blue.svg?logo=telegram)](https://t.me/taichi91) [![OnePlus Kernel Manifest](https://img.shields.io/badge/OnePlus%20Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/OnePlusOSS/kernel_manifest)

# Action-Build  
**```Build OnePlus SukiSU Ultra KPM Kernel```**

# Announcement  

The ``_x`` suffix in the config file indicates your current system version.  
``_v`` means ``Android15``, ``_u`` means ``Android14``, ``_t`` means ``Android13``, no suffix usually indicates the factory default ``Android`` version for the device.

Some devices have issues with ``lz4kd``, currently under fix. **If you can't boot successfully, do NOT enable the ``ZRAM algorithm`` for now. Please back up your ``boot`` partition in advance!**

``OnePlus Ace5Pro(ColorOS) OnePlus 13(ColorOS)`` require special handling and replacement of ``dtbo.img``

Remember to press **Volume Down** to install the module.

# Changelog  
-- Temporarily fixed the boot issue for `OnePlus Ace5Pro` and `OnePlus 13`  
-- Added support for custom kernel suffix  <- **`beta`**  
```
1. When the custom kernel suffix is empty, a random string is used instead of the default “x.xx.xxx-androidxx-8-o-g3b1e97b8b29f”
2. When custom suffix is enabled, the kernel version becomes “x.xx.xxx-androidxx-CUSTOM”, and the default androidxx-8-o-g3b1e97b8b29f is no longer used
```
-- ``KPM`` is enabled by default and can no longer be disabled  
-- Support for specifying the corresponding ``Android`` version in the ``ak3.zip``  
```
AnyKernel3_SukiSUUltra_12866_oneplus_ace2pro_Android15_KPM_VFS.zip
```
-- Added ``dir4`` and ``dir5`` paths to support ``sm8750`` and certain models after enabling ZRAM (e.g. ``ace2p``, ``13T``)  
-- Added ``LZ4K`` compression algorithm support for the ``zram`` module  
-- Removed possible ``_v`` or ``_u`` suffixes from config filenames  
-- Synced changes from the upstream ``susfs`` module download channel to resolve download issues  
-- Optimized ``build`` strategy for ``sm8750`` and ``sm7675``  
-- Fixed version number issues  
-- Added ``dir3`` path to support ``sm8475`` (e.g. ``ace2``)  
-- Support for automatically downloading the latest ``CI/Release`` ``susfs`` module and installing via ``ksud``  
-- Support for ``KPM`` (no manual modification or copying needed) and optional ``VFS HOOK``