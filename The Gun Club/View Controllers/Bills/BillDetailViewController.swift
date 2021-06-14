//
//  BillDetailViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/21/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import SafariServices

class BillDetailViewController: UITableViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var sponsorLabel: UILabel!
    @IBOutlet weak var dateIntroducedLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var viewOnlineLabel: UILabel!
    @IBOutlet weak var viewOnlineCell: UITableViewCell!
    @IBOutlet weak var sponsorCell: UITableViewCell!
    @IBOutlet weak var lastActionLabel: UILabel!
    @IBOutlet weak var lastActionTitleLabel: UILabel!
    
    var bill: Bill?
    var sponsor: CongressPerson?
    var billModelController: BillModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        navigationItem.titleView = NavigationBarLogoView()
        updateUI()
        billModelController?.retreiveSponsorInfo(for: bill!, completion: {[unowned self] (sponsor) in
            guard let sponsor = sponsor else { return }
            self.sponsor = sponsor
            DispatchQueue.main.async {
                self.sponsorCell.accessoryType = .disclosureIndicator
            }
        })
    }

    func updateUI() {
        guard let bill = bill else {return}
        titleLabel.text = bill.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        idLabel.text = bill.billId
        sponsorLabel.text = bill.sponsor
        dateIntroducedLabel.text = bill.dateIntroduced
        summaryLabel.text = bill.summary
        lastActionLabel.text = bill.latestAction
        lastActionTitleLabel.text = "Last action (\(bill.lastActionDate)):"
        if (URL(string: bill.billUrl) != nil) {
            viewOnlineCell.accessoryType = .disclosureIndicator
            viewOnlineLabel.isHidden = false
        } else {
            viewOnlineCell.accessoryType = .none
            viewOnlineLabel.isHidden = true
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    @objc func presentBillWebpage() {
        guard let bill = bill, let url = URL(string: bill.billUrl) else {return}
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webIndexPath = IndexPath(row: 1, section: 0)
        if indexPath == webIndexPath {
            presentBillWebpage()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == "contactSegue" else {return true}
        if sponsor == nil {
            return false
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSegue" {
            let navController = segue.destination as! UINavigationController
            let destinationViewController = navController.topViewController as! CongressPersonContactViewController
            if let sponsor = sponsor {
                destinationViewController.billSponsor = sponsor
            }
        }
    }
    //Done button unwind
    @IBAction func unwindFromSponsor(_ sender: UIStoryboardSegue) {
        
    }

}
