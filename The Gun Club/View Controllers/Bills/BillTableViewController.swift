//
//  BillTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/21/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit

class BillTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    deinit {
        print("Bill table deinit")
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splashScreen: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var bills: [Bill] = []
    let restRequests = RestApiCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isHidden = true
        self.splashScreen.isHidden = false
        loadingActivityIndicator.style = .large
        loadingActivityIndicator.startAnimating()
        fetchBills()
    }
    
    func stringForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
    
    func arrayForKey(_ key: String) -> [String]? {
        return (Bundle.main.infoDictionary?[key] as? [String])
    }
    
    func fetchBills() {
        guard let baseURL = stringForKey("Base Bill API URL"), let queries = arrayForKey("Bill API Queries"), let url = URL(string: baseURL) else {return}
        queries.forEach({
            var request = URLRequest(url: url.withQueries(["query": $0])!)
            request.addValue("azYX08cQYJkFJ7mBvXq22sIkLmE5fLhuRlNJVZ6g", forHTTPHeaderField: "X-API-Key")
            restRequests.retreiveCurrentBills(request, completion: {[weak self] (bills, error) in
                guard let self = self else {return}
                if let bills = bills {
                    bills.forEach({
                        if !self.bills.contains($0) && self.validateBillTitle($0.title) {
                            self.bills.append($0)
                        }
                        DispatchQueue.main.async {
                            self.tableView.isHidden = false
                            self.loadingActivityIndicator.stopAnimating()
                            self.splashScreen.isHidden = true
                            self.tableView.reloadData()
                        }
                    })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
        let bill = bills[indexPath.row]
        cell.textLabel?.text = bill.title
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = bill.isActive ? "Status: Active" : "Status: Introduced"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
