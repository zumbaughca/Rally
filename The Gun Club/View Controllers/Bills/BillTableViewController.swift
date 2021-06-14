//
//  BillTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/21/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit

class BillTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Observer {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splashScreen: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    
    var billModelController: BillModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isHidden = true
        self.tableView.register(BillTableViewCell.self, forCellReuseIdentifier: "customBillCell")
        self.splashScreen.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavigationBarLogoView())
        loadingActivityIndicator.style = .large
        loadingActivityIndicator.startAnimating()
        setStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        billModelController?.observer = self
        billModelController?.fetchBills()
    }

    func setStyle() {
        tableView.separatorStyle = .none
    }
    
    func dataDidUpdate() {
        tableView.isHidden = false
        loadingActivityIndicator.stopAnimating()
        splashScreen.isHidden = true
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billModelController?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customBillCell", for: indexPath) as! BillTableViewCell
        let bill = billModelController?.getBill(at: indexPath.row)
        cell.selectionStyle = .none
        cell.billTitle.text = bill?.title
        cell.introducedLabel.text = "Introduced: \(bill?.dateIntroduced ?? "")"
        cell.lastActionDateLabel.text = "Last action: \(bill?.lastActionDate ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "billDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "billDetailSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let bill = billModelController?.getBill(at: indexPath.row)
            let destinationViewController = segue.destination as? BillDetailViewController
            destinationViewController?.bill = bill
            destinationViewController?.billModelController = billModelController
        }
    }
}
