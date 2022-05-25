//
//  searchViewController.swift
//  A1_A2_iOS_Vraj_C0852332
//
//  Created by Vraj Patel on 25/05/22.
//

import UIKit
import MapKit

protocol citySearchOutcome {
    func citySearched(item : MKMapItem)
}

class searchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textsearchcity: UITextField!
    @IBOutlet weak var navigationbar: UINavigationBar!
    
    var mapView : MKMapView?
    var matchingItems:[MKMapItem] = []
    var delegate : citySearchOutcome?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func buttonSearch(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = textsearchcity.text!
        request.region = mapView!.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems.removeAll()
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }

    }
    @IBAction func barBackbutton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension searchViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell") as!
        searchTableViewCell
        cell.label.text = matchingItems[indexPath.row].placemark.title ?? ""
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.citySearched(item: matchingItems[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

}
