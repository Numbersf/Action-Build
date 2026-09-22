**`简体中文`** | [English](README-en.md)
 
[![Workflow Status](https://img.shields.io/github/actions/workflow/status/Numbersf/Action-Build/Build%20Kernel%20OnePlus.yml?branch=KernelSU-Next&label=remote%20build&logo=github-actions&style=flat-square)](https://github.com/Numbersf/Action-Build/actions/workflows/Build%20Kernel%20OnePlus.yml?query=branch%3AKernelSU-Next) ![Downloads](https://img.shields.io/github/downloads/Numbersf/Action-Build/total)
 
[![Kernel Manifest](https://img.shields.io/badge/Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/OnePlusOSS/kernel_manifest) [![Dynamic Kernel Manifest](https://img.shields.io/badge/Dynamic%20Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/Numbersf/kernel_manifest) [![Kernel Manifest Appendix](https://img.shields.io/badge/Kernel%20Manifest%20Appendix-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/Numbersf/Kernel_Manifest_Appendix) [![Fengchi Kernel](https://img.shields.io/badge/Fengchi%20Kernel-EB0029?logo=github&logoColor=white&style=flat-square)](https://github.com/Numbersf/SCHED_PATCH)
 
[![Channel](https://img.shields.io/badge/Follow-Telegram-blue.svg?logo=telegram)](https://t.me/AndroidCoreLayer) [![Coolapk](https://img.shields.io/badge/Follow-Coolapk-3DDC84?style=flat-square&logo=android&logoColor=white)](http://www.coolapk.com/u/28259173)
 
<img align="right" src="pic/zakozako~.svg" width="100px" alt="zakozako~">
 
# Action-Build
 
<img src="https://readme-typing-svg.demolab.com?font=Meslo+Nerd+Font&size=32&duration=2800&pause=2000&color=A855F7&center=true&vCenter=true&width=940&lines=Welcome+to+Action+Build!;Build+Kernels+For+All+OnePlus+Devices;Your+Device,+Your+Rules!;%E6%9B%B4%E9%AB%98%E6%95%88+%E6%9B%B4%E5%85%A8%E9%9D%A2+%E6%9B%B4%E5%BF%AB%E9%80%9F+%E6%9B%B4%E7%A8%B3%E5%AE%9A+%E5%85%A8%E8%87%AA%E5%8A%A8%E5%8C%96">
 
禁止宣传**没有任何修改**的`fork`仓库，详见[LICENSE](LICENSE)
<details>
<summary><strong>点击查看如何fork项目</strong></summary>
<p>
  <img src="https://github.com/Numbersf/Action-Build/blob/KernelSU-Next/pic/start.gif" width="500"/>
  <img src="https://github.com/Numbersf/Action-Build/blob/KernelSU-Next/pic/start(2).png" width="500"/>
</p>
<summary>请注意，如果你想使用其他分支管理器项目，请在fork时关闭“仅复制SukiSU-Ultra分支”</summary>
</details>
 
<details>
<summary><strong>点击查看如何同步fork后的项目到最新</strong></summary>
<p>
  <img src="https://github.com/Numbersf/Action-Build/blob/KernelSU-Next/pic/syncfork.png" width="500"/>
</p>
<summary>请及时同步!某些更新可能会导致旧版失效报错!如果同步后依旧运行失败请删除并重新fork!完成以上步骤后仍有问题再反馈提交issue</summary>
</details>
 
# 公告
 
------
> [!NOTE]
>配置文件中最后的一个``_？``后缀是你正在使用系统版本的代号。而无后缀的大部分是出厂``Android``版本。**``Android16``起从``_b``开始重新计算。** 判断具体的适用安卓版本请手动打开清单,手动改成其他代号,前提是它们确实存在。
> <details>
> <summary><strong>点击查看详细的版本代号</strong></summary>
>
>>`_？ Android19 (？)`
>
>>`_？ Android18 (？)`<strong>
>
>>`_c Android17 (Cinnamon Bun)`
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
>关于要跑多久的问题的数据参考
>
>|| 平均耗时范围|最大耗时|
>|------------------|----------------------|------------|
>| `极速构建所有机型` | `1st:17min ~ 36min 2nd:6min ~ 17min` | `40/29min`|
>| `内核版本5.10-5.15使用官方脚本构建` | `20min ~ 35min`| `45min`    |
>| `内核版本6.1-6.12使用官方脚本构建` | `55min ~ 1h12min`| `1h28min` |
>
> >使用ccache第一次可能会减速、仅极速构建生效
>
> >repo工具版本差异可能会影响耗时
>
>也就是说,如果你运行的时长超过了对应机型的最高时间,请暂停重新运行并查看step,看看有没有占用时间过长的步骤,特别注意Initialize Repo and Sync这一步,受到上游REPO工具链的影响会经常出问题.这一步超过15min可以重新尝试一次,如果依旧失败请等待修复
 
------
> [!CAUTION]
>
>如果你开启了``ZRAM``算法,请在刷入``Anykernel3``重启**前**安装``ZRAM``模块,部分参数请自行调整。另外``5.10``内核暂不支持开启``ZRAM``算法,因为没有找到``zram.ko``路径,但是生成的``Anykernel3``依旧可用  
>
>``MTK``设备不支持关闭极速构建  
>
>``OnePlus Ace5``不支持开启风驰,较老的机型即使内核加入也无法使用,不要勉强  
>
 
------
 
# 开发中的功能
- [ ] Kexec内核热切换支持
- [ ] 全内核版本风驰支持
- 牙膏要一点一点挤,显卡要一刀一刀切,PPT要一张一张放,代码要一行一行写,更多功能及优化...敬请期待....
 
# 更新日志
>小的更新内容将被忽略 更多内容请参看提交
 
- 新增`FakeConfig(HideConfig)`，用于隐藏`proc/config.gz`内配置项可见性  
```
普通配置项:
set_config "CONFIG_IP_NF_TARGET_ECN=y"
隐藏配置项:
set_hide_config "CONFIG_IP6_NF_NAT=y"
```  
 
- 新增`FakePatch`完善多内核等级与`susfs`的兼容问题  
 
- 新增路径递推,完整适配内核版本`6.12+`的`Rust`构建逻辑和`bindgen`、`Kleaf`依赖搜索  
 
- `lz4`自动跟随上游升级以及自动纠错  
 
- 完整适配`DroidSpaces`+`Ntsync`  
 
- 完整适配`Re:Kernel`,自动跟随上游  
 
- 多处启用外部警告-检查`fork源`是否正常、内核后缀构建时间是否存在异常符号调用等  
 
- 完整的`KPN`修补支持  
 
- 可在设置中直接调整`ZRAM`开关、算法名、大小,自动处理`ZRAM附加模块`,附加模块来自[@FURLC](https://github.com/FURLC)  
 
- 完整版`Unicode Bypass`支持,适配全内核版本  
 
- 首发修复`MTK-5.10`构建报错  
 
- 首发新增支持大量`MTK`机型,清单和路径问题成功被攻克  
 
- 支持修改`SUSFS`哈希值进行回退(此项输入`-1`则关闭`SUSFS`)、调用`SUSFS-DEV`开发分支  
 
- 内核版本为`6.6-6.12`支持将设备树中的`type`属性从`HMBIRD_OGKI`替换为`HMBIRD_GKI`;支持开启风驰驱动[@reigadegr](https://github.com/reigadegr) [@cctv18](https://github.com/cctv18) [@Numbersf](https://github.com/Numbersf) [@HanKuCha](https://github.com/HanKuCha)  
 
- 允许调用第三方动态源码清单仓库,以支持原本不兼容的机型。必须确保源码清单与频道分支的命名符合规范。在第三方清单仓库的`README.md`中,如未定义`CPUD`,可填写任意占位值。此外,极速构建必须保持启用,不可关闭  
 
- 支持`Baseband-guard(LSMBBG)`  
 
- 支持设置分支、自定义版本标识、修改对应分支的提交哈希来进行回退  
```
设置分支:分为管理器层和内置层,请按照KernelSU Next仓库频道名进行修改,非开发者禁止修改,不可留空、删除
这里指的提交hash是内置层
必须用两个/(U+002F)隔开,不可删除
```  
 
- 全自动化获取内核信息及构建信息  
 
- 允许修改内核等级`SUBLEVEL`,用于欺骗系统-解决系统更新后`SUBLEVEL`改变但内核源码没有更新导致的验证而无法开机的问题  
 
- 删除`file-map`及编译方式并由主工作流自行选择[@Bouteillepleine](https://github.com/Bouteillepleine)  
 
- 首发支持全机型、全编译方式自定义内核构建时间`UTS_VERSION`  
 
- 使用`ccache-ECS`、`ltothin-cache`、`apt-cache`共同加速工作流,仅开启极速构建`fast build`有效,第一次使用、重大更新需要换`key`要重新生成`cache`,可能会降低速度  
```
你可以通过使用delete.yml(name: Workflow and Cache Cleanup)工作流开启“是否删除所有缓存”的选项来删除所有的key
也可以去
https://github.com/你的用户名(username)/你的仓库名/actions/caches
直接手动删除对应的key
当内核级别更新、GitHub上游工具链改变导致的速度明显变慢时,就需要进行以上操作
```  
 
- 首发适配内核版本`6.6+`的`setlocalversion`文件中`echo`新格式,修复自定义&随机伪官方后缀失效。现在,全机型、全编译方式完美支持此功能  
 
- 修复`ZRAM`无法使用或者打不开非系统应用的问题  
 
- 修复内核版本介于`5.15.0-5.15.123`之间官方脚本跑不出,极速编译结果有问题[@zzh20188](https://github.com/zzh20188)  
 
- 允许自定义内核后缀← **`beta`**
```
1.当自定义内核后缀为空时,使用随机字符串,不再是默认的“x.xx.xxx-androidxx-8-o-g3b1e97b8b29f”
2.当自定义启用时,修改内核为“x.xx.xxx-androidxx-自定义内容”,同时也不再保留androidxx-8-o-g3b1e97b8b29f
3.当使用Fast Build(极速构建)时,为新的源内核信息x.xx.xxx-o-g3b1e97b8b29f添加缺失的内核android版本号,再进行1或2中的操作
```  
 
- 支持极速编译`(5.10[首发]、5.15[首发]、6.1、6.1+)`  
 
- 支持显示自己填入的内容在`Debug Show Selected Inputs`这一步,同时工作流名称也可以看到一些东西  
 
- 从写入 `Anykernel3.zip` 的配置文件后缀中删除潜在的版本代码,替换成精确的 `Android` 版本号`XX.X.(X)`
```
AnyKernel3_KernelSUNext_34895_OnePlusAce2Pro_Android16.0.0(5.15.180)_KPM_BBG_ILH_DS_REKER.zip
AnyKernel3_KernelSUNext_34895_OnePlus11_Android14.1.0(5.15.123)_KPM_BBG_ILH_DS_REKER.zip
AnyKernel3_KernelSUNext_34895_OnePlus15(AOSP)_Android16.0.0(6.12.23)_KPM_BBG_ILH_DS_REKER.zip
```  
 
- 添加 `zram` 模块的 `LZ4K、LZ4KD` 压缩算法支持[@ShirkNeko](https://github.com/ShirkNeko)  
 
- 支持自动下载最新 `CI/Release` 的 `susfs` 模块并调用 `ksud` 安装、自动获取不同类型的管理器`CI-APK`解压到`Anykernel3`但不安装  
 