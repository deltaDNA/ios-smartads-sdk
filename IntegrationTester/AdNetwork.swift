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

import Foundation
import DeltaDNAAds

protocol AdNetworkDelegate : class {
    func update()
}

class AdNetwork : NSObject {
    let name: String
    let config: NSDictionary
    let adapter: DDNASmartAdAdapter?
    var adLoaded : Bool
    var adResult : String
    var showedAd : Bool
    var clickedAd : Bool
    var leftApplication : Bool
    var closedAd : Bool
    var canReward : Bool
    var adCount : Int
    
    weak var delegate : AdNetworkDelegate?
    
    init(name: String, className: String, config: NSDictionary) {
        self.name = name
        let c: NSMutableDictionary = NSMutableDictionary(dictionary: config)
        c["eCPM"] = 1
        self.config = c
        self.adapter = AdNetwork.construct(className: className, config: c)
        self.adLoaded = false
        self.adResult = ""
        self.showedAd = false
        self.clickedAd = false
        self.leftApplication = false
        self.closedAd = false
        self.canReward = false
        self.adCount = 0
        super.init()
        self.adapter?.delegate = self
    }
    
    static func construct(className: String, config: NSDictionary) -> DDNASmartAdAdapter? {
    
        let klass = NSClassFromString(className) as? DDNASmartAdAdapter.Type
        let adapter = klass?.init(configuration: config as! [AnyHashable: Any], waterfallIndex: 1)
        if adapter == nil {
            print("Failed to initialise adapter for \(className)")
        }
        return adapter
    }
    
    func logo() -> UIImage? {
        let imageName : String = self.name.components(separatedBy: " ")[0] + ".png"
        return UIImage(named: imageName)
    }
    
    func version() -> String {
        return adapter?.version ?? "unknown"
    }
    
    func isAdAvailable() -> Bool {
        return self.adLoaded
    }
    
    func requestAd() {
        self.adLoaded = false
        self.adResult = ""
        self.showedAd = false
        self.clickedAd = false
        self.leftApplication = false
        self.closedAd = false
        self.canReward = false
        self.delegate?.update()
        self.adapter?.requestAd()
    }
    
    func showAd(viewController: UIViewController) {
        self.adapter?.showAd(from: viewController)
        self.delegate?.update()
    }
}

extension AdNetwork : DDNASmartAdAdapterDelegate {
    func adapterTimeoutSeconds() -> UInt {
        return 15;
    }

    
    func adapterDidLoadAd(_ adapter: DDNASmartAdAdapter!) {
        self.adLoaded = true
        self.adResult = "Loaded"
        self.delegate?.update()
    }
    
    func adapterDidFail(toLoadAd adapter: DDNASmartAdAdapter!, with result: DDNASmartAdRequestResult!) {
        print("Failed to load \(self.name) ad: \(result.desc)\nerror: \(result.errorDescription)")
        self.adLoaded = false
        self.adResult = String(format: "%@\n%@", result.desc, result.errorDescription ?? "")
        self.delegate?.update()
    }
    
    func adapterIsShowingAd(_ adapter: DDNASmartAdAdapter!) {
        print("Showing \(self.name) ad")
        self.showedAd = true
        self.adCount += 1
        self.delegate?.update()
    }
    
    func adapterDidFail(toShowAd adapter: DDNASmartAdAdapter!, with result: DDNASmartAdShowResult!) {
        print("Failed to show \(self.name) ad: \(result.desc!)")
        self.showedAd = false
        self.delegate?.update()
    }
    
    func adapterWasClicked(_ adapter: DDNASmartAdAdapter!) {
        self.clickedAd = true
        self.delegate?.update()
    }
    
    func adapterLeftApplication(_ adapter: DDNASmartAdAdapter!) {
        self.leftApplication = true
        self.delegate?.update()
    }
    
    func adapterDidCloseAd(_ adapter: DDNASmartAdAdapter!, canReward: Bool) {
        self.closedAd = true
        self.canReward = canReward
        self.adResult = ""
        self.delegate?.update()
    }
    
    func sessionAdCount() -> Int {
        return self.adCount
    }
}
