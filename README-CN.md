![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA智能广告iOS SDK

deltaDNA智能广告SDK用于将你的iOS游戏接入我们的智能广告中间平台。它同时支持空闲广告和奖励广告。

### 使用CocoaPods安装

[CocoaPods](https://cocoapods.org/)是一个Objective-C的依赖关系管理器，可以非常简便的自动使用第三方库。这可以使智能广告能够直截了当的选择要支持的广告网络。

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNAAds', '~> 1.0'
```

deltaDNA的SDK可以直接从我们的私有项目库中找到，其URL必须作为一个源路径添加到你的Podfile。deltaDNA广告（DeltaDNAAds）依附于我们的分析SDK，其也需要被安装。

上面的例子将安装我们支持的所有广告网络。如若只安装一个子集，那么需要在你的podfile中分别声明每一个子项。例如：

```ruby

pod 'DeltaDNAAds/AdMob'
pod 'DeltaDNAAds/AdColony'

```
可用的子项列表可以从项目根目录中的`DeltaDNAAds.podspec`文件中找到。

### 用法

将SDK的头文件包括进来。

```objective-c
#include <DeltaDNA/DeltaDNA.h>
#include <DeltaDNAAds/DeltaDNAAds.h>
```

启用分析SDK。

```objective-c
[DDNASDK sharedInstance].clientVersion = @"1.0";

[[DDNASDK sharedInstance] startWithEnvironmentKey:@"YOUR_ENVIRONMENT_KEY"
                                       collectURL:@"YOUR_COLLECT_URL"
                                        engageURL:@"YOUR_ENGAGE_URL"];


```

标记广告。

```objective-c
[[DDNASmartAds sharedInstance] registerForAds];
```

你可以使用`isInterstitialAdAvailable`函数测试一个空闲广告是否可以显示。

通过调用`showInterstitialAdFromRootViewController:`函数展示一个空闲广告。

你可以使用`isRewardedAdAvailable`函数测试一个奖励广告是否可以显示。

通过调用`showRewardedAdFromRootViewController:`函数展示一个奖励广告。

你可能会需要为DDNASmartAds对象设置权限，所以这个SDK的行为才可以报告给你。

```objective-c
[DDNASmartAds sharedInstance].interstitialDelegate = self;
[DDNASmartAds sharedInstance].rewardedDelegate = self;
```

更多细节请查看[DDNASmartAds.h](https://github.com/deltaDNA/ios-smartads-sdk/blob/master/DeltaDNAAds/SmartAds/DDNASmartAds.h)。

## 授权

该资源适用于Apache 2.0授权。
