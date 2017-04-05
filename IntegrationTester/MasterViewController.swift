//
//  MasterViewController.swift
//  SmartAdsIntegrationTester
//
//  Created by David White on 31/03/2017.
//
//

import UIKit
import SwiftyJSON

protocol AdNetworkSelectionDelegate: class {
    func adNetworkSelected(newAdNetwork: AdNetwork)
}

class MasterViewController: UITableViewController {
    
    var adNetworks = [AdNetwork]()
    
    weak var delegate: AdNetworkSelectionDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        if let url = Bundle.main.url(forResource: "networks", withExtension: "json") {
            let jsonData = try? Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let json = JSON(st: jsonData!)
            for (i, n): (String, JSON) in json["networks"] {
                print(i, n)
                let c = NSMutableDictionary()
                for (k, v): (String, JSON) in n["config"].dictionary! {
                    c[k] = v.object
                }
                let network = AdNetwork(name: n["name"].string!, className: n["klass"].string!, config: c)
                self.adNetworks.append(network)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.adNetworks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let adNetwork = self.adNetworks[indexPath.row]
        cell.textLabel?.text = adNetwork.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAdNetwork = self.adNetworks[indexPath.row]
        self.delegate?.adNetworkSelected(newAdNetwork: selectedAdNetwork)
        
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
