//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import DeltaDNAAds

class ViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    @IBOutlet weak var interstitialAdLabel: UILabel!
    @IBOutlet weak var rewardedAdLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    
    var interstitialAd: DDNAInterstitialAd?
    var rewardedAd: DDNARewardedAd?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.logoImageView.image = UIImage(named: "Logo.png")
        self.sdkVersionLabel.text = DDNASmartAds.sdkVersion()
        self.interstitialAdLabel.text = "Registering..."
        self.rewardedAdLabel.text = "Registering..."
        
        DDNASDK.setLogLevel(DDNALogLevel.debug)
        DDNASDK.sharedInstance().clientVersion = "1.0.0"
        DDNASDK.sharedInstance().hashSecret = "KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw"
        DDNASmartAds.sharedInstance().registrationDelegate = self
        
        DDNASDK.sharedInstance().start(withEnvironmentKey: "55822530117170763508653519413932",
                                       collectURL: "https://collect2010stst.deltadna.net/collect/api",
                                       engageURL: "https://engage2010stst.deltadna.net")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInterstitialAd(_ sender: AnyObject) {
        let interstitialAd = DDNAInterstitialAd(delegate: self)
        interstitialAd?.show(fromRootViewController: self)
        self.interstitialAd?.delegate = nil
        self.interstitialAd = interstitialAd
    }
    
    @IBAction func showInterstitialAdWithDecisionPoint(_ sender: AnyObject) {
        DDNASmartAds.sharedInstance().engageFactory.requestInterstitialAd(forDecisionPoint: "interstitialAd", handler: {
            (interstitialAd: DDNAInterstitialAd) -> Void in
            interstitialAd.delegate = self
            interstitialAd.show(fromRootViewController: self)
        })
    }
    
    @IBAction func showRewardedAd(_ sender: AnyObject) {
        let rewardedAd = DDNARewardedAd(delegate: self)
        rewardedAd?.show(fromRootViewController: self)
        self.rewardedAd?.delegate = nil
        self.rewardedAd = rewardedAd
    }
    
    @IBAction func showRewardedAdWithDecisionPoint(_ sender: AnyObject) {
        DDNASmartAds.sharedInstance().engageFactory.requestRewardedAd(forDecisionPoint: "rewardedAd1", handler: {
            (rewardedAd: DDNARewardedAd) -> Void in
            rewardedAd.delegate = self
            rewardedAd.show(fromRootViewController: self)
            
            self.rewardedAd = rewardedAd
        })
    }
}

extension ViewController: DDNASmartAdsRegistrationDelegate {
    func didRegisterForInterstitialAds() {
        print("Registered for interstitial ads.")
        self.interstitialAdLabel.text = "Registered for interstitial ads."
    }
    func didFailToRegisterForInterstitialAds(withReason reason: String) {
        print("Failed to register for interstitial ads: \(reason).")
        self.interstitialAdLabel.text = "Failed to register for interstitial ads."
    }
    func didRegisterForRewardedAds() {
        print("Registered for rewarded ads.")
        self.rewardedAdLabel.text = "Registered for rewarded ads."
    }
    func didFailToRegisterForRewardedAds(withReason reason: String) {
        print("Failed to register for rewarded ads: \(reason).")
        self.rewardedAdLabel.text = "Failed to register for rewarded ads."
    }
}

extension ViewController: DDNAInterstitialAdDelegate {
    func didOpen(_ interstitialAd: DDNAInterstitialAd!) {
        print("Opened interstitial ad.")
    }
    func didFail(toOpen interstitialAd: DDNAInterstitialAd!, withReason reason: String!) {
        print("Failed to open interstitial ad: \(reason).")
    }
    func didClose(_ interstitialAd: DDNAInterstitialAd!) {
        print("Closed interstitial ad.")
    }
}

extension ViewController: DDNARewardedAdDelegate {
    func didLoad(_ rewardedAd: DDNARewardedAd!) {
        print("Loaded rewarded ad.")
    }
    func didExpire(_ rewardedAd: DDNARewardedAd!) {
        print("Expired rewarded ad.")
    }
    func didOpen(_ rewardedAd: DDNARewardedAd!) {
        print("Opened rewarded ad.")
    }
    func didFail(toOpen rewardedAd: DDNARewardedAd!, withReason reason: String!) {
        print("Failed to open rewarded ad.")
    }
    func didClose(_ rewardedAd: DDNARewardedAd!, withReward reward: Bool) {
        print("Closed rewarded ad with reward = \(reward)")
    }
}

extension ViewController: DDNAImageMessageDelegate {
    func didReceiveResources(for imageMessage: DDNAImageMessage!) {
        if let rewardAmount = imageMessage.parameters["rewardAmount"] {
            self.rewardLabel.text = String(format: "Reward player $\(rewardAmount).")
        } else {
            self.rewardLabel.text = "No reward available."
        }
        imageMessage.show(fromRootViewController: self)
    }
    func didFailToReceiveResources(for imageMessage: DDNAImageMessage!, withReason reason: String!) {
        print("Failed to download resources for image message: \(reason)")
    }
    func onActionImageMessage(_ imageMessage: DDNAImageMessage!, name: String!, type: String!, value: String!) {
        print("Image message actioned.")
    }
    func onDismiss(_ imageMessage: DDNAImageMessage!, name: String!) {
        print("Image message dismissed.")
    }
}
