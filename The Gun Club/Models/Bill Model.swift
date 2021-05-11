//
//  Bill Model.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/20/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

struct BillTopLevel: Codable {
    let results: [BillResults]
}

struct BillResults: Codable {
    let bills: [Bill]
}

struct Bill: Codable, Equatable, Comparable {
    
    let billId: String
    let title: String
    let sponsor: String
    let sponsorId: String
    let billUrl: String
    let dateIntroduced: String
    let isActive: Bool
    var summary: String
    let latestAction: String
    let lastActionDate: String
    
    private enum CodingKeys: String, CodingKey {
        case billId = "number"
        case title
        case sponsor = "sponsor_name"
        case sponsorId = "sponsor_id"
        case billUrl = "congressdotgov_url"
        case dateIntroduced = "introduced_date"
        case isActive = "active"
        case summary
        case latestAction = "latest_major_action"
        case lastActionDate = "latest_major_action_date"
    }
    
    private func formatSummary(_ summary: String) -> String {
        if summary == "" || summary == " " {
            return "Not available"
        } else {
            return summary
        }
    }
    
    static func == (lhs: Bill, rhs: Bill) -> Bool {
        return lhs.billId == rhs.billId
    }
    
    static func < (lhs: Bill, rhs: Bill) -> Bool {
        guard let left = lhs.lastActionDate.getDateFromString(), let right = rhs.lastActionDate.getDateFromString() else { return false }
        return left < right
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.billId = try valueContainer.decode(String.self, forKey: .billId)
        self.title = try valueContainer.decode(String.self, forKey: .title)
        self.sponsor = try valueContainer.decode(String.self, forKey: .sponsor)
        self.sponsorId = try valueContainer.decode(String.self, forKey: .sponsorId)
        self.billUrl = try valueContainer.decode(String.self, forKey: .billUrl)
        self.dateIntroduced = try valueContainer.decode(String.self, forKey: .dateIntroduced)
        self.isActive = try valueContainer.decode(Bool.self, forKey: .isActive)
        self.summary = try valueContainer.decode(String.self, forKey: .summary)
        self.latestAction = try valueContainer.decode(String.self, forKey: .latestAction)
        self.lastActionDate = try valueContainer.decode(String.self, forKey: .lastActionDate)
        self.summary = formatSummary(self.summary)
    }
}
