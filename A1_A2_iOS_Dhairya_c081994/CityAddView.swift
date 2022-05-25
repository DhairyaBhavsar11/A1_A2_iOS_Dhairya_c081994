//
//  CityAddView.swift
//  A1_A2_iOS_Dhairya_c081994
//
//  Created by dhairya bhavsar on 2022-05-25.
//

import UIKit
import MapKit

protocol SearchCityResult {
    func searchedCity(item : MKMapItem)
}

class CityAddView: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var tblView: UITableView!
    
    var MpVIew : MKMapView?
    
    var matchingItems:[MKMapItem] = []
    
    var delegate : SearchCityResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnSearchTap(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = txtSearch.text!
        request.region = MpVIew!.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems.removeAll()
            self.matchingItems = response.mapItems
            self.tblView.reloadData()
        }

    }
    @IBAction func barBackTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension CityAddView : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellRslt") as!
        CellRslt
        cell.lblTitle.text = matchingItems[indexPath.row].placemark.title ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchedCity(item: matchingItems[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}

