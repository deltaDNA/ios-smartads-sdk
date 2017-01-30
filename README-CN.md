![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA智能广告iOS SDK

[![Build Status](https://travis-ci.org/deltaDNA/ios-smartads-sdk.svg)](https://travis-ci.org/deltaDNA/ios-smartads-sdk)

deltaDNA智能广告SDK用于将你的iOS游戏接入我们的智能广告中间平台。它同时支持空闲广告和奖励广告。

### 使用CocoaPods安装

[CocoaPods](https://cocoapods.org/)是一个Objective-C的依赖关系管理器，可以非常简便的自动使用第三方库。这可以使智能广告能够直截了当的选择要支持的广告网络。

#### Podfile

```ruby
source 'https://github.com/deltaDNA/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'MyApp' do
    pod 'DeltaDNAAds', '~> 1.2'
end
```

deltaDNA的SDK可以直接从我们的私有项目库中找到，其URL必须作为一个源路径添加到你的Podfile。DeltaDNAAds依附于我们的分析SDK，其也需要被安装。

上面的例子将安装我们支持的所有广告网络。如若只安装一个子集，那么需要在你的podfile中分别声明每一个子项。例如：

```ruby
source 'https://github.com/deltaDNA/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'MyApp' do
    pod 'DeltaDNAAds', '~> 1.2', :subspecs => ['AdMob','MoPub']
end
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
[DDNASmartAds sharedInstance].registrationDelegate = self;
[[DDNASmartAds sharedInstance] registerForAds];
```

如果一切顺利，智能广告服务将开始在后台抓取广告。如果服务成功配置，那么`DDNASmartAdsRegistrationDelegate`方法将报告：

* `-didRegisterForInterstitialAds` - 当空闲广告成功配置后调用。
* `-didFailToRegisterForInterstitialAdsWithReason:` - 如果空闲广告因某些原因无法正常配置时调用。
* `-didRegisterForRewardedAds` - 当奖励广告成功配置后调用。
* `-didFailToRegisterForRewardedAdsWithReason:` - 当奖励广告因某些原因无法正常配置时调用。

#### 创建一个空闲广告

一个空闲广告是一个全屏的弹出窗口，玩家可以通过关闭按钮关闭。为了显示一个空闲广告，需要创建一个`DDNAInterstitialAd`，然后显示它。

```objective-c
DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:self];
if (interstitialAd != nil) {
    [interstitialAd showFromRootViewController:self];
}
```

这个案例假设你在一个`UIViewController`中，而且你已经实现了`DDNAInterstitialAdDelegate`的代理方法。测试`interstitialAd`不为空（NIL）非常重要，这时如果你想要显示一个广告，你必须得到一个实际的返回对象。初始化会检查会话限制、时间限制以及一个广告已经被加载并且可以供显示。无论何时你尝试创建一个广告，一个*adShow*事件都会被记录，这报告了未能创建一个广告的原因，因此广告效果可以被准确跟踪。不要反复尝试创建一个广告直到你得到一个，你应当尝试一次，如果没有可用的再继续。

以下回调由`DDNAInterstitialAdDelegate`提供：

* `-didOpenInterstitialAd:` - 当广告在屏幕显示时调用。
* `-didFailToOpenInterstitialAd:withReason:` - 如果广告因某些原因未能打开时调用。
* `-didCloseInterstitialAd:` - 当广告被关闭时调用。

请确保你对空闲对象的充分调用，否则代理方法可能无法被调用。当你想要显示另一个广告时，你可以重新使用这个空闲对象并再次调用`-showFromRootViewController`或者创建另一个。

#### 创建一个奖励广告

奖励广告是一个短视频，通常为30秒长，玩家在可以关闭前必须观看。要显示一个奖励广告，需要创建一个`DDNARewardedAd`对象然后显示它。

```objective-c
DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:self];
if (rewardedAd != nil) {
    [rewardedAd showFromRootViewController:self];
}
```

这个案例再次假设你在一个`UIViewController`中，而且你已经实现了`DDNARewardedAdDelegate`的代理方法。如果一个非空对象被返回，你可以调用`-showFromRootViewController`。初始化广告会检查当前你在这个点有权显示一个广告并且一个广告已经加载。

下面的回调由`DDNARewardedAdDelegate`提供：

* `-didOpenRewardedAd:` - 当广告在屏幕显示时调用。
* `-didFailToOpenRewardedAd:withReason:` - 如果广告因某些原因未能打开时调用。
* `-didCloseRewardedAd:withReward:` - 当广告完成，且广告标志位表明广告是否已经被足够观看从而你可以奖励玩家时调用。

同样，请确保你对奖励广告对象的充分引用，否则代理方法可能无法被调用。当你想要显示另一个广告时可以重新使用这个奖励广告对象或者创建另一个。

#### 使用吸引（Engage）

要充分利用deltaDNA的智能广告的优势，你需要使用我们的吸引（Engage）服务。如果游戏要向某个特定玩家展示一个广告，那么需要使用吸引（Engage）。吸引（Engage）将根据哪个活动在进行以及玩家在哪个分组中来定制响应。你可以尝试从一个`DDNAEngagement`对象创建一个广告，其将只会在吸引（Engage）响应允许时能够成功。我们还可以添加游戏可以使用的额外参数到吸引（Engage）响应中，也许可以为玩家自定义奖励。有关吸引（Engage）的更多详细信息请查看[分析SDK](https://github.com/deltaDNA/ios-sdk)。

```objective-c
DDNAEngagement* engagement = [DDNAEngagement engagementWithDecisionPoint:@"showRewardedAd"];

[[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement* response) {

    DDNARewardedAd* rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:response delegate:self];
    if (rewardedAd != nil) {

        // 查看什么奖励被提供
        if (rewardedAd.parameters[@"rewardAmount"]) {
            NSInteger rewardAmount = [rewardedAd.parameters[@"rewardAmount"] integerValue];

            // 当前提供给玩家...

            // 如果他们选择观看广告
            [rewardedAd showFromRootViewController:self];
        }
    }
}];
```

查看包含的案例项目以了解更多详细信息。

#### 遗留接口

除了创建`DDNAInterstitialAd`和`DDNARewardedAd`对象，仍然可以直接使用`DDNASmartAds`对象。

你可以使用`-isInterstitialAdAvailable`测试一个空闲广告是否可以显示。通过调用`-showInterstitialAdFromRootViewController:`显示一个空闲广告。你可以使用`-isRewardedAdAvailable`测试一个奖励广告是否准备好显示。通过调用`-showRewardedAdFromRootViewController:`显示一个奖励广告。

使用决策点（Decision Points）的其他展示方法现在已经被弃用，因为它们隐藏了什么吸引（Engage）被返回。这将阻止你控制是否以及何时在你的游戏中展示广告。

你还可以为DDNASmartAds对象设置代理，因此SDK行为将会报告给你。

```objective-c
[DDNASmartAds sharedInstance].interstitialDelegate = self;
[DDNASmartAds sharedInstance].rewardedDelegate = self;
```

查看[DDNASmartAds.h](https://github.com/deltaDNA/ios-smartads-sdk/blob/master/DeltaDNAAds/SmartAds/DDNASmartAds.h)以了解更多信息。

### iOS 10

下面的表格是整合库时的注意事项表。只有一半的广告网络完全符合ATS，其他的[推荐](https://firebase.google.com/docs/admob/ios/ios9)设置`NSArbitararyLoads`键值为真（true）。现在多数支持bitcode，但是目前我们不支持。只有MobPub和Flurry使用CocoaPods `use_frameworks!`选项，其他的都会给出一个转换依赖错误。这个库还没有被写成支持动态框架，所有现在应避免这样。请记住如果你只想将已确定的网络包含到智能网络中，你可以使用subspecs选项。

|  广告网络  |   iOS 10支持   |   ATS支持   | Bitcode |    框架    | 备注  |
|------------|----------------|-------------|---------|------------|-------|
| AdMob      | YES (v7.11)    | YES (v7.13) | YES     | NO         |       |
| Amazon     | YES (v2.15)    | NO          | YES     | NO         | 查看[iOS 10整合](https://developer.amazon.com/public/apis/earn/mobile-ads/ios/docs/release-notes)      |
| MoPub      | YES (v4.9.1)   | YES (v4.10) | YES     | YES        |       |
| Flurry     | NO (v7.6.6)    | NO          | YES     | YES        |       |
| InMobi     | YES (v6.0.0)   | YES (v6.0.0)| YES     | NO         | 仅限企业版 |
| MobFox     | YES (v2.3.3)   | NO          | NO      | NO         |       |
| AdColony   | NO (v3.0)      | YES         | YES     | NO         | 查看[iOS 10整合](https://github.com/AdColony/AdColony-iOS-SDK/wiki/Xcode-Project-Setup#configuring-privacy-controls) |
| Chartboost | YES (v6.5.1)   | YES (v6.5.1)| YES     | NO         |       |
| Vungle     | YES (v4.0.5)   | NO          | YES     | NO         |       |
| UnityAds   | YES (v2.0)     | YES (v2.0.5)| NO      | NO         |       |

## 授权

该资源适用于Apache 2.0授权。
