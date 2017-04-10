//
//  DetailViewController.swift
//  SmartAdsIntegrationTester
//
//  Created by David White on 31/03/2017.
//
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resultLabel: VerticalTopAlignLabel!
    @IBOutlet weak var showedSwitch: UISwitch!
    @IBOutlet weak var clickedSwitch: UISwitch!
    @IBOutlet weak var leftApplicationSwitch: UISwitch!
    @IBOutlet weak var closedSwitch: UISwitch!
    @IBOutlet weak var adsShown: UILabel!
    @IBOutlet weak var rewardedLabel: UILabel!
    
    @IBAction func requestAd(_ sender: AnyObject) {
        self.adNetwork?.requestAd()
    }
    
    @IBAction func showAd(_ sender: AnyObject) {
        self.adNetwork?.showAd(viewController: self)
    }
    
    var adNetwork: AdNetwork! {
        willSet (newAdNetwork) {
            adNetwork?.delegate = nil
        }
        didSet {
            adNetwork?.delegate = self
            self.refreshUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshUI() {
        if let adNetwork = adNetwork {
            logoImageView?.image = adNetwork.logo()
            versionLabel?.text = adNetwork.version()
            nameLabel?.text = adNetwork.name
            resultLabel?.text = adNetwork.adResult
            showedSwitch?.isOn = adNetwork.showedAd
            clickedSwitch?.isOn = adNetwork.clickedAd
            leftApplicationSwitch?.isOn = adNetwork.leftApplication
            closedSwitch?.isOn = adNetwork.closedAd
            adsShown?.text = adNetwork.adCount > 0 ? String(format: "x\(adNetwork.adCount)") : ""
            if adNetwork.closedAd {
                rewardedLabel?.text = adNetwork.canReward ? "reward" : "no reward"
            } else {
                rewardedLabel?.text = ""
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController: AdNetworkSelectionDelegate {
    func adNetworkSelected(newAdNetwork: AdNetwork) {
        adNetwork = newAdNetwork
    }
}

extension DetailViewController: AdNetworkDelegate {
    func update() {
        refreshUI()
    }
}
