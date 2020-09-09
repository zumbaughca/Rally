//
//  LocationSearchTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/11/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchDelegate {
    func didSelectLocation(location: MKMapItem)
}

class LocationSearchTableViewController: UITableViewController, UISearchResultsUpdating {

    var delegate: LocationSearchDelegate?
    var matchingItems: [MKMapItem] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: {(response, error) in
            if error != nil {
            }
            guard let response = response else {return}
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = matchingItems[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectLocation(location: matchingItems[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
