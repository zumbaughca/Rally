//
//  AttendingRallysViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/19/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import MapKit

class AttendingRallysViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var attendingRallys: [Rally] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        attendingRallys = Rally.loadAttendingRallys()
        attendingRallys.sort()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return attendingRallys.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rallyCell", for: indexPath)
        let rally = attendingRallys[indexPath.row]
        cell.textLabel?.text = rally.name
        cell.detailTextLabel?.text = "On \(rally.date)"
        return cell
      }
      
      
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
