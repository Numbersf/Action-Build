**`Enlish`** | [简体中文](README.md)
 
[![Build](https://img.shields.io/badge/GitHub%20Actions-Build-181717?logo=github&logoColor=white&style=flat-square)](https://github.com/Numbersf/Action-Build/actions/workflows/Build%20SukiSU%20Ultra%20OnePlus.yml) [![Channel](https://img.shields.io/badge/Follow-Telegram-blue.svg?logo=telegram)](https://t.me/taichi91) [![OnePlus Kernel Manifest](https://img.shields.io/badge/OnePlus%20Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/OnePlusOSS/kernel_manifest) [![Coolapk](https://img.shields.io/badge/Follow-Coolapk-3DDC84?style=flat-square&logo=android&logoColor=white)](http://www.coolapk.com/u/28259173)
 
<img align="right" src="pic/zakozako~.svg" width="100px" alt="zakozako~">
 
# Action-Build
**```Build All OnePlus Devices SukiSU Ultra Kernel```**
> More efficient · More comprehensive · More Faster · More stable
 
<details>
<summary><strong>Click to view how to fork the project</strong></summary>
<img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/make.gif" width="500"/>
</details>
 
<details>
<summary><strong>Click to view how to sync the forked project to the latest</strong></summary>
<p>
  <img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/syncfork.png" width="150"/>
  <img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/syncfork(2).png" width="150"/>
</p>
<summary>Please sync promptly! Some updates may cause older versions to fail! If it still fails after syncing, delete and fork again! If the issue persists, then submit an issue for feedback.</summary>
</details>
 
# Announcements
 
------
> [!NOTE]
> The final ``_？`` suffix in the configuration file represents the code name of the Android version you are currently using.Most entries without a suffix correspond to the factory default ``Android`` version. **Starting from ``Android16``, the suffixes are recalculated beginning from ``_b``.** To determine which Android version a configuration applies to, manually open the list and change the suffix to another code name—provided that the corresponding suffix actually exists.
> <details>
> <summary><strong>Click to view the Android version codes</strong></summary>
>
>>`_？ Android19 (？)`
>
>>`_？ Android18 (？)`
>
>>`_c Android17 (Cinnamon Bun)`<strong>
>
>>`_b Android16 (Baklava)`
>
>>`_v Android15 (Vanilla Ice Cream)`
>
>>`_u Android14 (Upside Down Cake)`
>
>>`_t Android13 (Tiramisu)`
>
>>`_s Android12 (Snow Cone)`</strong>
>
> </details>
 
------
> [!IMPORTANT]
>Data reference on the question of how long to run
>
>|| Average Duration Range|Maximum Duration|
>|------------------|----------------------|------------|
>| `Ultra-fast build for all devices` | `1st:19min ~ 35min 2nd:9min ~ 19min` | `42min`|
>| `Kernel versions 5.10–5.15 built using official script` | `29min ~ 35min`| `45min`    |
>| `Kernel versions 6.1-6.12 built using official script` | `59min ~ 1h12min`| `1h28min` |
>
> >Using ccache may slow down the first build; this only applies to ultra-fast builds.
>
> >Differences in repo tool versions may affect the build time.
>
>So, if your build time exceeds the maximum time for your model, please stop and rerun, and check the steps, especially the Initialize Repo and Sync step. This often fails due to upstream REPO toolchain issues. If this step takes more than 15min, try again. If it still fails, wait for a fix
 
------
> [!CAUTION]
> Do not use volume down to install modules during root-retaining updates, use volume up to skip! Generally, installation is no longer necessary, just use the SukiSU Ultra Add-on Module  
>
> If your kernel is ``6.6``, and you previously used the official script to build,but now want to use ``Fast Build``, please **restore** the following images first:`dtbo.img`, ``system_dlkm(.erofs).img``,**otherwise the device may fail to boot!**  
>
> If you have enabled the ``ZRAM`` algorithm, make sure to install the ``ZRAM`` module **before rebooting** after flashing with ``Anykernel3``. You may need to adjust some parameters manually.The 5.10 kernel is not supported ``ZRAM`` , as the ``zram.ko`` module path could not be found.However, the generated ``Anykernel3`` is still usable  
>
>``OnePlus Ace5`` does not support enabling Fengchi. Older models cannot use it even if the kernel includes it — do not force it  
>
>``CAll Build Start UP`` is an **extremely dangerous** new workflow.**It has no new features and everything remains default and non-customizable**.This workflow is **strictly prohibited** for regular users and should use ``Build OnePlus_SukiSU Ultra All`` instead!  
>
 
------
 
# Features in Development
- [ ] ccache supports AB update mode
- Toothpaste should be squeezed bit by bit, GPUs should be cut slice by slice, PPTs should be shown slide by slide, and code should be written line by line — more features and optimizations... stay tuned!
 
# Changelog
> Minor updates will be ignored. For more details, please refer to the commit.
 
- Supports modifying the `SUSFS` hash for rollback and supports using the `SUSFS-DEV` development branch.
 
- For kernel versions `6.6–6.12`, supports replacing the `type` property in the device tree from `HMBIRD_OGKI` to `HMBIRD_GKI`; supports enabling Fengchi Driver[@reigadegr](https://github.com/reigadegr) [@cctv18](https://github.com/cctv18) [@Numbersf](https://github.com/Numbersf) [@HanKuCha](https://github.com/HanKuCha)  
 
- Allow calling third-party dynamic source manifest repositories to support originally incompatible devices. It is essential to ensure that the naming of the source manifest and channel branches complies with the specifications. In the third-party manifest repository's `README.md`, if `CPUD` is not defined, any placeholder value can be used,the fast build feature must remain enabled and cannot be disabled.  
 
- Support `Baseband-guard(LSMBBG)`.  
 
- Support setting branches、custom version identifiers、fallback hash.  
```
Set Branch: Change the original `susfs-main` to another `builtin` branch. Please modify according to the channel name in the SukiSU Ultra repository. Do not modify unless you are a developer. Do not leave it empty or remove it.
Custom Version Tag:
Replace the original commit hash with your custom content, and move the commit hash to the end. This can be modified freely, but keep it reasonably short.
v3.1.7-f5541e21@builtin
↓
v3.1.7-CustomContent@builtin[f5541e21]
If you don’t want to use a custom version tag, just leave it empty (e.g. susfs-main/).
Regardless of whether the custom version identifier and fallback hash are enabled, they must be separated by two /(U+002F) and cannot be removed
```  
 
- Fully automated retrieval of kernel information and build information.  
 
- Allow modifying `SUBLEVEL`,Used to fix the issue where the device fails to boot after a system update changes the `SUBLEVEL` but the kernel source has not been updated.  
 
- Allows running multiple workflows in batches of `9` each time.Ordinary users are prohibited from using.  
 
- Remove file-map and build method selection; let the main workflow decide automatically [@Bouteillepleine](https://github.com/Bouteillepleine)  
 
- First to support custom kernel build time `UTS_VERSION` for all device models and all build methods.  
 
- Use `ccache` to speed up the workflow, only effective when `fast build` is enabled.The cache needs to be regenerated by changing the `key` when using it for the first time or after major updates, which may reduce the speed.
```
You can delete all keys by enabling the "是否删除所有缓存" option in the delete.yml(name: Workflow and Cache Cleanup) workflow.
You can also go to
https://github.com/your-username/your-repository-name/actions/caches
to manually delete the corresponding keys.  
When there is a kernel-level update or a significant slowdown caused by changes in the GitHub upstream toolchain, you need to perform the above actions.
```  
 
- First to support for the kernel version `6.6+` new `setlocalversion` format using `echo`, fixing the issue where custom and randomly-generated pseudo-official suffixes were not applied. Now, this feature is fully supported across all device models and build methods.  
 
- Add `TRUSTY_EXISTS` to automatically detect whether the `6.6` kernel has defects in the kernel source code and determine whether `sed` is needed.  
 
- When `ZRAM` is enabled, automatically download and modify the ZRAM additional module.[@FURLC](https://github.com/FURLC)  
 
- Fix issues where `ZRAM` is unusable or unable to launch non-system apps.  
 
- Fix the problem that the official script cannot run when the kernel version is between `5.15.0-5.15.123`, and the result of the quick compilation has problems. [@zzh20188](https://github.com/zzh20188)  
 
- Allow custom kernel suffix← **`beta`**
```
1. When the custom kernel suffix is empty, a random string is used instead of the default “x.xx.xxx-androidxx-8-o-g3b1e97b8b29f”
2. When custom suffix is enabled, the kernel version is modified to “x.xx.xxx-androidxx-CustomContent”, and the original “androidxx-8-o-g3b1e97b8b29f” is no longer retained.
3. When using clang make (Fast Build), add the missing kernel android version number to the new source kernel information x.xx.xxx-o-g3b1e97b8b29f, and then perform operations in 1 or 2.
```  
 
- Support fast-build `(5.10[Debut], 5.15[Debut], 6.1, 6.6)`.  
 
- Support displaying user-defined inputs during `Debug Show Selected Inputs` step; workflow name will also reflect some values.  
 
- Removed potential version codes from the suffix of `Anykernel3.zip` config file, replaced with exact `Android` version numbers `XX.X.X`.
```
AnyKernel3_SukiSUUltra_12896_oneplus_ace2pro_Android15.0.0_KPM_VFS.zip
AnyKernel3_SukiSUUltra_12896_oneplus_13_Android15.0.2_KPM_VFS.zip
AnyKernel3_SukiSUUltra_12896_oneplus_11_Android14.1.0_KPM_VFS.zip
```  
 
- Added support for the `LZ4K、LZ4KD` compression algorithm in the `zram` module.   [@ShirkNeko](https://github.com/ShirkNeko)  
 
- Support automatic download of latest `CI` version of `susfs` module and install via `ksud`; also automatically extracts different types manager `CI-APK` but does not install it.  
 