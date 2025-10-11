**`简体中文`** | [English](README-en.md)
 
[![Build](https://img.shields.io/badge/GitHub%20Actions-Build-181717?logo=github&logoColor=white&style=flat-square)](https://github.com/Numbersf/Action-Build/actions/workflows/Build%20SukiSU%20Ultra%20OnePlus.yml) [![Channel](https://img.shields.io/badge/Follow-Telegram-blue.svg?logo=telegram)](https://t.me/taichi91) [![OnePlus Kernel Manifest](https://img.shields.io/badge/OnePlus%20Kernel%20Manifest-EB0029?logo=oneplus&logoColor=white&style=flat-square)](https://github.com/OnePlusOSS/kernel_manifest) [![Coolapk](https://img.shields.io/badge/Follow-Coolapk-3DDC84?style=flat-square&logo=android&logoColor=white)](http://www.coolapk.com/u/28259173)
 
<img align="right" src="pic/zakozako~.svg" width="100px" alt="zakozako~">
 
# Action-Build
**```Build All OnePlus Devices SukiSU Ultra Kernel```**
>更高效 更全面 更快速 更稳定
 
<details>
<summary><strong>点击查看如何fork项目</strong></summary>
<img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/make.gif" width="500"/>
</details>
 
<details>
<summary><strong>点击查看如何同步fork后的项目到最新</strong></summary>
<p>
  <img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/syncfork.png" width="150"/>
  <img src="https://github.com/Numbersf/Action-Build/blob/SukiSU-Ultra/pic/syncfork(2).png" width="150"/>
</p>
<summary>请及时同步!某些更新可能会导致旧版失效报错!如果同步后依旧运行失败请删除并重新fork!完成以上步骤后仍有问题再反馈提交issue</summary>
</details>
 
# 公告
 
------
> [!NOTE]
>配置文件中的``_x``后缀是你正在使用系统版本的代号。**倒序字母小写递增**。而无后缀的大部分是出厂``Android``版本(并不绝对请注意清单内部信息)。目前我只在预选中添加了``Android15``的机型也就是``_v``后缀,如果你在使用其他的安卓版本,请手动将``_v``改成其他代号,前提是它们确实存在
> <details>
> <summary><strong>点击查看详细的版本代号(部分未来可能会有改变)</strong></summary>
>
>>`_z Android19 (Zebra Cake)`
>
>>`_y Android18 (Yogurt Parfait)`
>
>>`_x Android17 (Xmas Pudding)`
>
>>`_w Android16 (Wedding Cake)`<strong>
>
>>`_v Android15 (Vanilla Ice Cream)`
>
>>`_u Android14 (Upside Down Cake)`
>
>>`_t Android13 (Tiramisu)`
>
>>`_s Android12 (Snow Cone)`</strong>
>
>>`_r Android11 (Red Velvet Cake)`
>
>>`_q Android10 (Quince Tart)`
>
>>`_p Android9 (Pie)`
>
>>`_o Android8 (Oreo)`
>
>>`_n Android7 (Nougat)`
>
>>`_m Android6 (Marshmallow)`
>
>>`_l Android5 (Lollipop)`
>
>>`_k Android4.4 (KitKat)`
>
>>`_j Android4.3–4.1 (Jelly Bean)`
>
>>`_i Android4.0 (Ice Cream Sandwich)`
>
>>`_h Android3.x (Honeycomb)`
>
>>`_g Android2.3 (Gingerbread)`
>
>>`_f Android2.2 (FroYo)`
>
>>`_e Android2.1 (Eclair)`
>
>>`_d Android1.6 (Donut)`
>
>>`_c Android1.5 (Cupcake)`
>
> </details>
 
------
> [!IMPORTANT]
>关于要跑多久的问题的数据参考
> <details>
> <summary><strong>点击查看使用极速编译clang make的用时</strong></summary>
>
>| 机型类型                     | 平均耗时范围        | 最大耗时   |
>|------------------------|---------------------|------------|
>| `≥Android15` | `1st:19min ~ 35min 2nd:9min ~ 19min` | `42min`|
>| `<Android15`| `1st:27min ~ 40min 2nd:18min ~ 30min`| `50min` |
>
> >使用ccache第一次会减速
>
> >repo工具版本差异可能会影响耗时
> </details>
>
> <details>
> <summary><strong>点击查看使用官方build.sh的用时</strong></summary>
>
>
>| 机型类型             | 平均耗时范围           | 最大耗时   |
>|----------------------|------------------------|------------|
>| `sm8450,sm8475,sm8550` | `29min ~ 35min`| `45min`    |
>| `sm7675,sm7550,sm8650` | `59min ~ 1h12min`| `1h28min` |
>| `sm8750+`| `1h1min ~ 1h8min`| `1h24min`     |
>|`<Android15`| `39min ~ 49min`| `59min` |
>
> >repo工具版本差异可能会影响耗时
></details>
>
>也就是说,如果你运行的时长超过了对应机型的最高时间,请暂停重新运行并查看step,看看有没有占用时间过长的步骤,特别注意Initialize Repo and Sync这一步,受到上游REPO工具链的影响会经常出问题.这一步超过15min可以重新尝试一次,如果依旧失败请等待修复
 
------
> [!CAUTION]
>请不要在**保``root``更新**时音量下安装模块请使用音量上跳过!现在也基本上不需要安装了,使用``SukiSU Ultra附加模块``即可  
>
>如果你的内核版本是``6.6``,并且曾经使用了官方脚本构建,而现在需要使用``Fast Build(极速构建)``,请先还原``dtbo.img、system_dlkm(.erofs).img``**否则会无法开机!**  
>
>如果你开启了``ZRAM``算法,请在刷入``Anykernel3``重启**前**安装``ZRAM``模块,部分参数请自行调整。另外``5.10``内核暂不支持开启``ZRAM``算法,因为没有找到``zram.ko``路径,但是生成的``Anykernel3``依旧可用  
>
>``OnePlus Ace5``不支持开启风驰,较老的机型即使内核加入也无法使用,不要勉强  
>
>``CAll Build Start UP``是一个极其危险的新工作流文件,**它没有新功能且一切保持默认不可自定义**,新工作流**禁止**普通用户使用!普通用户请使用``Build OnePlus_SukiSU Ultra All``!  
>
 
------
 
# 开发中的功能
- [ ] ccache支持AB更新模式
- 牙膏要一点一点挤,显卡要一刀一刀切,PPT要一张一张放,代码要一行一行写,更多功能及优化...敬请期待....
 
# 更新日志
>小的更新内容将被忽略 更多内容请参看提交
 
- 允许调用第三方动态源码清单仓库,以支持原本不兼容的机型。必须确保源码清单与频道分支的命名符合规范。在第三方清单仓库的``README.md``中,如未定义``CPUD``,可填写任意占位值。此外,极速构建功能必须保持启用,不可关闭  
 
- 支持``Baseband-guard(LSMBBG)``  
 
- 支持设置分支、自定义版本标识、修改对应分支的提交``hash``来进行回退  
```
设置分支:原susfs-main改成其他susfs-*分支,请按照SukiSU Ultra仓库频道名进行修改,非开发者禁止修改,不可留空、删除
自定义版本标识:
将原先的提交hash改成自定义内容,再将提交hash放在最后 这个可以随意改,不要太长
v3.1.7-f5541e21@susfs-*
↓
v3.1.7-自定义内容@susfs-*[f5541e21]
当你不想起用自定义版本标识时,就留空(susfs-main/)
无论是否启用自定义版本标识和回退hash,必须用两个/(U+002F)隔开,不可删除
```  
 
- 移除``KPM``除配置项以外的支持,你可以在安装``Anykernel3``时通过``SukiSU Ultra``自带的``KPM``修补工具进行修补  
 
- 全自动化获取内核信息及构建信息  
 
- 允许修改`SUBLEVEL`,用于解决系统更新后`SUBLEVEL`改变而内核源码没有更新导致的无法开机的问题,默认关闭,默认值为`99`,有需要自行修改  
```
6.1.75->6.1.99
```  
 
- 允许分批次每次9个运行多个工作流,普通用户禁止使用  
 
- 删除`file-map`及编译方式并由主工作流自行选择[@Bouteillepleine](https://github.com/Bouteillepleine)  
 
- 首发支持全机型、全编译方式自定义内核构建时间`UTS_VERSION`  
 
- 使用`ccache`加速工作流,仅开启极速构建`fast build`有效,第一次使用、重大更新需要换`key`要重新生成`cache`,可能会降低速度  
```
你可以通过使用delete.yml(name: 清理工作流运行记录和缓存)工作流开启“是否删除所有ccache缓存”的选项来删除所有的key
也可以去
https://github.com/你的用户名(username)/你的仓库名/actions/caches
直接手动删除对应的key
当内核级别更新、GitHub上游工具链改变导致的速度明显变慢时,就需要进行以上操作
```  
 
- 首发适配`sm8750`的`setlocalversion`文件中`echo`新格式,修复自定义&随机伪官方后缀失效。现在,全机型、全编译方式完美支持此功能  
 
- 添加`TRUSTY_EXISTS`用于自动检测`6.6`内核是否内核源码存在缺陷,判断是否`sed`处理  
 
- 支持**部分机型**开启风驰驱动(自选是否开启),驱动来自[@HanKuCha](https://github.com/HanKuCha)  
 
- 当`ZRAM`开启时,自动下载并修改`ZRAM附加模块`,附加模块来自[@FURLC](https://github.com/FURLC)  
 
- 修复`ZRAM`无法使用或者打不开非系统应用的问题  
 
- 修复内核版本介于`5.15.0-5.15.123`之间官方脚本跑不出,极速编译结果有问题[@zzh20188](https://github.com/zzh20188)  
 
- 允许自定义内核后缀← **`beta`**
```
1.当自定义内核后缀为空时,使用随机字符串,不再是默认的“x.xx.xxx-androidxx-8-o-g3b1e97b8b29f”
2.当自定义启用时,修改内核为“x.xx.xxx-androidxx-自定义内容”,同时也不再保留androidxx-8-o-g3b1e97b8b29f
3.当使用Fast Build(极速构建)时,为新的源内核信息x.xx.xxx-o-g3b1e97b8b29f添加缺失的内核android版本号,再进行1或2中的操作
```  
 
- 支持极速编译`(5.10[首发]、5.15[首发]、6.1、6.6)`  
 
- 修复`OnePlus Ace5Pro、OnePlus 13`跑不出来或者无法开机问题,直接使用官方`dtbo`就可以直接开机[@reigadegr](https://github.com/reigadegr)  
 
- 支持显示自己填入的内容在`Debug Show Selected Inputs`这一步,同时工作流名称也可以看到一些东西  
 
- 从写入 `Anykernel3.zip` 的配置文件后缀中删除潜在的版本代码,替换成精确的 `Android` 版本号`XX.X.X`
```
AnyKernel3_SukiSUUltra_12896_oneplus_ace2pro_Android15.0.0_KPM_VFS.zip
AnyKernel3_SukiSUUltra_12896_oneplus_13_Android15.0.2_KPM_VFS.zip
AnyKernel3_SukiSUUltra_12896_oneplus_11_Android14.1.0_KPM_VFS.zip
```  
 
- 添加 `zram` 模块的 `LZ4K` 压缩算法支持[@ShirkNeko](https://github.com/ShirkNeko)  
 
- 支持自动下载最新 `CI/Release` 的 `susfs` 模块并调用 `ksud` 安装、自动获取管理器`CI-APK`解压到`Anykernel3`但不安装  
 