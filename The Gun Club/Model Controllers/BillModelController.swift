//
//  BillModelController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 6/2/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation

class BillModelController: Observable {
    
    private var bills = [Bill]()
    private let networkModule: Network
    weak var observer: Observer?
    
    var count: Int {
        return bills.count
    }
    
    var isEmpty: Bool {
        return bills.isEmpty
    }
    
    init(networkModule: Network, observer: Observer?) {
        self.networkModule = networkModule
        self.observer = observer
        
    }
    
    func getBills() -> [Bill] {
        return bills
    }
    
    func getBill(at index: Int) -> Bill? {
        if index >= bills.count {
            return nil
        } else {
            return bills[index]
        }
    }
    
    /*
     * Bills are added in reverse order (Bill with latest action at top of table.
     * Once all bills are added to the array, we call completion.
     * Then need to update the UI on the main thread after method returns.
     */
    func fetchBills() {
        guard let baseURL = self.stringForKey("Base Bill API URL"), let queries = arrayForKey("Bill API Queries"), let url = URL(string: baseURL),
              let apiKey = self.stringForKey("Propublica API Key") else {return}
        queries.forEach({
            var request = URLRequest(url: url.withQueries(["query": $0])!)
            request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
            networkModule.restApiCall(request, completion: {[weak self] (bills: BillTopLevel?, error: Error?) in
                guard let self = self else { return }
                if let bills = bills?.results[0].bills {
                    bills.forEach({
                        if !self.bills.contains($0) && self.validateBillTitle($0.title) {
                            self.bills.insertInReverseOrder($0)
                        }
                    })
                    DispatchQueue.main.async {
                        self.notifyObserver()
                    }
                }
            })
        })
        
    }
    
    func retreiveSponsorInfo(for bill: Bill, completion: @escaping (CongressPerson?) -> Void) {
        guard let baseUrl = self.stringForKey("Base Member URL") else {return}
        guard let apiKey = self.stringForKey("Propublica API Key") else {return}
        let memberUrl = baseUrl + bill.sponsorId + ".json"
        guard let url = URL(string: memberUrl) else {return}
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        networkModule.restApiCall(request, completion: {
            (member: CongressPersonTopLevel?, error: Error?) in
            if let member = member {
                let sponsor = member.results[0]
                completion(sponsor)
            }
        })
    }
    
    private func validateBillTitle(_ title: String) -> Bool {
        if title.lowercased().contains("gun") || title.lowercased().contains("firearm") {
            return true
        } else {
            return false
        }
    }
    
    private func stringForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
    
    private func arrayForKey(_ key: String) -> [String]? {
        return (Bundle.main.infoDictionary?[key] as? [String])
    }
    
    internal func notifyObserver() {
        observer?.dataDidUpdate()
    }
}
