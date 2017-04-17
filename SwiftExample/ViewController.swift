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
        
        DDNASDK.sharedInstance().clientVersion = "1.0.0"
        DDNASDK.sharedInstance().hashSecret = "KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw"
        DDNASDK.sharedInstance().start(withEnvironmentKey: "55822530117170763508653519413932",
                                       collectURL: "https://collect2010stst.deltadna.net/collect/api",
                                       engageURL: "https://engage2010stst.deltadna.net")
        
        DDNASmartAds.sharedInstance().registrationDelegate = self
        DDNASmartAds.sharedInstance().registerForAds()
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
        let engagement = DDNAEngagement(decisionPoint: "showInterstitial")
        DDNASDK.sharedInstance().request(engagement, engagementHandler: {
            (response: DDNAEngagement?) -> Void in
            if (response != nil) {
                if let interstitialAd = DDNAInterstitialAd(engagement: response, delegate: self) {
                    interstitialAd.show(fromRootViewController: self)
                    self.interstitialAd?.delegate = nil
                    self.interstitialAd = interstitialAd
                } else {
                    print("Engage prevented you showing an ad at this time.")
                }
            } else {
                print("Engage didn't respond, no campaign set up so move on.")
            }
        })
    }
    
    @IBAction func showRewardedAd(_ sender: AnyObject) {
        let rewardedAd = DDNARewardedAd(delegate: self)
        rewardedAd?.show(fromRootViewController: self)
        self.rewardedAd?.delegate = nil
        self.rewardedAd = rewardedAd
    }
    
    @IBAction func showRewardedAdWithDecisionPoint(_ sender: AnyObject) {
        let engagement = DDNAEngagement(decisionPoint: "showRewarded")
        DDNASDK.sharedInstance().request(engagement, engagementHandler: {
            (response: DDNAEngagement?) -> Void in
            if (response != nil) {
                if let rewardedAd = DDNARewardedAd(engagement: response, delegate: self) {
                    rewardedAd.show(fromRootViewController: self)
                    self.rewardedAd?.delegate = nil
                    self.rewardedAd = rewardedAd
                } else {
                    print("Engage prevented you showing an ad at this time.")
                }
            } else {
                print("Engage didn't respond, no campaign set up so move on.")
            }
        })
    }
    
    @IBAction func showRewardedAdOrImageMessage(_ sender: AnyObject) {
        print("Show rewarded ad or image message.")
        // make request to engage
        let engagement = DDNAEngagement(decisionPoint: "rewardOrImage")
        DDNASDK.sharedInstance().request(engagement) { (response: DDNAEngagement?) in
            // get the response
            if let response = response {
                print("Got a response from engage: \(response.raw).")
                
                // try and build a rewarded ad
                let rewardedAd: DDNARewardedAd? = DDNARewardedAd(engagement: response, delegate: self)
                
                // try and build an image message
                let imageMessage: DDNAImageMessage? = DDNAImageMessage(engagement: response, delegate: self)
                
                // ad will succeed if engagement contains no ad related parameters, so see if image message is valid, else show the ad...
                if let imageMessage = imageMessage {
                    print("Got an image message!")
                    // we got an image message to show, fetch it's resources
                    imageMessage.fetchResources()
                } else if let rewardedAd = rewardedAd {
                    print("Got a rewarded ad!")
                    if let rewardAmount = rewardedAd.parameters["rewardAmount"] {
                        self.rewardLabel.text = String(format: "Reward for watching $\(rewardAmount).")
                    } else {
                        self.rewardLabel.text = "No reward available 😢."
                    }
                    
                    // make offer to player... this like it so show the ad
                    
                    if (rewardedAd.isReady()) {
                        print("Showing the rewarded ad.")
                        rewardedAd.show(fromRootViewController: self)
                    } else {
                        print("Rewarded ad not ready.")
                    }
                } else {
                    print("Engage didn't give us anything so move on.")
                    self.rewardLabel.text = "No reward available 😢."
                }
            } else {
                print("Engage didn't respond, no campaign set up so move on.")
            }
        }
    }
}

extension ViewController: DDNASmartAdsRegistrationDelegate {
    func didRegisterForInterstitialAds() {
        print("Registered for interstitial ads.")
        self.interstitialAdLabel.text = "Registered for interstitial ads."
    }
    func didFailToRegisterForInterstitialAds(withReason reason: String!) {
        print("Failed to register for interstitial ads: \(reason).")
        self.interstitialAdLabel.text = "Failed to register for interstitial ads."
    }
    func didRegisterForRewardedAds() {
        print("Registered for rewarded ads.")
        self.rewardedAdLabel.text = "Registered for rewarded ads."
    }
    func didFailToRegisterForRewardedAds(withReason reason: String!) {
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
