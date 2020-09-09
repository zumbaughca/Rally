//
//  RallyDetailTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/13/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class RallyDetailTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var descriptorLabels: [UILabel]!
    @IBOutlet weak var buttonContentView: UIView!
    @IBOutlet weak var attendRallyButton: UIButton!
    @IBOutlet weak var numberOfAttendees: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var rally: Rally?
    var attendingRallys: [Rally] = []
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    let firebaseRequests = FirebaseRequests()
    var currentLocation: CLLocation?
    var distance: String?
    var isAttending: Bool = false {
        willSet {
            if newValue == true {
                attendRallyButton.setTitle("Unattend Rally", for: .normal)
            } else {
                attendRallyButton.setTitle("Attend Rally", for: .normal)
            }
        }
    }
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attendingRallys = Rally.loadAttendingRallys()
        self.mapView.delegate = self
        currentLocation = locationManager.location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        updateUI()
        tableView.separatorStyle = .none
    }

    func updateUI() {
         guard let rally = rally else {return}
        calculateDistance()
         formatLabelAppearance()
         nameLabel.text = rally.name
         dateAndTimeLabel.text = rally.date
         locationLabel.text = rally.address
         descriptionLabel.text = rally.description
        if attendingRallys.contains(rally) {
            isAttending = true
        } else {
            isAttending = false
        }
        
        numberOfAttendees.text = "\(rally.numberOfAttendees) people are going"
         geocoder.geocodeAddressString(rally.address, completionHandler: {(placemarks, error) in
             if error == nil {
                 if let placemark = placemarks?.first {
                     self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                 }
             }
         })
        firebaseRequests.attachRallyAttendanceObserver(rally.key, completion: {(value, error) in
            if let value = value {
                self.numberOfAttendees.text = "\(value) people are attending"
            }
        })
     }
    
    func calculateDistance() {
        guard let rally = rally else {return}
        let rallyLocation = CLLocation(latitude: CLLocationDegrees(rally.latitude), longitude: CLLocationDegrees(rally.longitude))
        if let distanceInMiles = currentLocation?.distance(from: rallyLocation).toMiles() {
            distance = String(distanceInMiles.round(to: 1)) + " miles away"
            distanceLabel.text = distance
        }
    }
    
    func formatLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: 25)
        descriptorLabels.forEach({$0.font = .boldSystemFont(ofSize: 22)})
        attendRallyButton.layer.cornerRadius = 15
    }
    
    func test() {
        functions.httpsCallable("attendRally").call(["key": rally!.key], completion: { (result, error) in
            if let result = result {
                print(result)
            }
        })
    }
    
    @IBAction func attendRallyButtonPressed(_ sender: Any) {
        if isAttending == false {
            test()
            //firebaseRequests.confirmRallyAttendance(rally!.key)
            attendingRallys.append(rally!)
            Rally.saveRallyAsAttending(attendingRallys)
            isAttending = true
        } else {
            //firebaseRequests.unattendRally(rally!.key)
            attendingRallys.removeAll(where: {$0 == rally!})
            Rally.saveRallyAsAttending(attendingRallys)
            isAttending = false
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 250
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
