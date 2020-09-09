//
//  CongressPersonContactViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/22/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import SafariServices

class CongressPersonContactViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var partyAndStateLabel: UILabel!
    
    var billSponsor: CongressPerson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        guard let billSponsor = billSponsor else {return}
        nameLabel.text = billSponsor.firstName + " " + billSponsor.lastName
        if let office = billSponsor.roles[0].office {
            officeLabel.text = office
        } else {
            officeLabel.text = "Not available"
        }
        if let _ = billSponsor.roles[0].phoneNumber {
            phoneButton.isHidden = false
        } else {
            phoneButton.isHidden = true
        }
        if let state = billSponsor.roles[0].state, let party = billSponsor.roles[0].party {
            partyAndStateLabel.text = "\(party), \(state)"
        } else {
            partyAndStateLabel.isHidden = true
        }
    }

    @IBAction func phoneButtonPressed(_ sender: Any) {
        guard let phoneNumber = billSponsor?.roles[0].phoneNumber else {return}
        if let phoneUrl = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(phoneUrl)
        }
    }
    
    @IBAction func webButtonPressed(_ sender: Any) {
        guard let billSponsor = billSponsor else {return}
        if let webURL = URL(string: billSponsor.webUrl) {
            let safariViewController = SFSafariViewController(url: webURL)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
}
