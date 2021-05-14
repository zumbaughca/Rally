//
//  BillTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/21/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit

class BillTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splashScreen: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    
    var bills: [Bill] = []
    let restRequests = Network()
    
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
        fetchBills(completion: {
            [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.loadingActivityIndicator.stopAnimating()
                self.splashScreen.isHidden = true
                self.tableView.reloadData()
            }
        })
        setStyle()
    }
    
    func setStyle() {
        tableView.separatorStyle = .none
    }

    func arrayForKey(_ key: String) -> [String]? {
        return (Bundle.main.infoDictionary?[key] as? [String])
    }
    
    /*
     * Bills are added in reverse order (Bill with latest action at top of table.
     * Once all bills are added to the array, we call completion.
     * Then need to update the UI on the main thread after method returns.
     */
    func fetchBills(completion: @escaping () -> Void) {
        guard let baseURL = self.stringForKey("Base Bill API URL"), let queries = arrayForKey("Bill API Queries"), let url = URL(string: baseURL),
              let apiKey = self.stringForKey("Propublica API Key") else {return}
        queries.forEach({
            var request = URLRequest(url: url.withQueries(["query": $0])!)
            request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
            restRequests.restApiCall(request, completion: {[weak self] (bills: BillTopLevel?, error: Error?) in
                guard let self = self else { return }
                if let bills = bills?.results[0].bills {
                    bills.forEach({
                        if !self.bills.contains($0) && self.validateBillTitle($0.title) {
                            self.bills.insertInReverseOrder($0)
                        }
                    })
                    completion()
                }
            })
        })
        
    }
    
    func validateBillTitle(_ title: String) -> Bool {
        if title.lowercased().contains("gun") || title.lowercased().contains("firearm") {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customBillCell", for: indexPath) as! BillTableViewCell
        let bill = bills[indexPath.row]
        cell.selectionStyle = .none
        cell.billTitle.text = bill.title
        cell.introducedLabel.text = "Introduced: \(bill.dateIntroduced)"
        cell.lastActionDateLabel.text = "Last action: \(bill.lastActionDate)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "billDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "billDetailSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let bill = bills[indexPath.row]
            let destinationViewController = segue.destination as? BillDetailViewController
            destinationViewController?.bill = bill
        }
    }
}
