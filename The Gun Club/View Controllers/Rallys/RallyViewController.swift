//
//  RallyViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/9/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class RallyViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var rallys: [Rally] = []
    let testCells = ["Test1"]
    let reference = Database.database().reference().child("Rallys")
    let locationManager = CLLocationManager()
    var userCurrentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchRallys()
        userCurrentLocation = locationManager.location
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rallys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rallyCell", for: indexPath)
        let rally = rallys[indexPath.row]
        let rallyLocation = CLLocation(latitude: CLLocationDegrees(rally.latitude), longitude: CLLocationDegrees(rally.longitude))
        if let distanceInMiles = userCurrentLocation?.distance(from: rallyLocation).toMiles() {
            cell.detailTextLabel?.text = "\(String(describing: distanceInMiles.round(to: 1))) miles away on \(rally.date)"
        }
        cell.textLabel?.text = rally.name
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fetchRallys() {
        let jsonDecoder = JSONDecoder()
        reference.observe(.childAdded, with: {[weak self] (snapshot) in
            guard let self = self else {return}
            if let dictionary = snapshot.value as? [String: Any] {
                    do {
                       let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                        if let rally = try? jsonDecoder.decode(Rally.self, from: data) {
                            if !rally.hasRallyOccured() {
                                self.rallys.append(rally)
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    } catch {
                        print("Error")
                    }
            }
        })
    }
    
    @IBAction func cancelUnwind(_ sender: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rallyDetailSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let selectedRally = rallys[indexPath.row]
            let destinationViewController = segue.destination as? RallyDetailTableViewController
            destinationViewController?.rally = selectedRally
        }
    }
}

