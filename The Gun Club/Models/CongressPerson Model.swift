//
//  CongressPerson Model.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/21/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

struct CongressPersonTopLevel: Codable {
    let results: [CongressPerson]
}
//Need to find what other info is relevant and finish API call method
struct CongressPerson: Codable {
    let firstName: String
    let lastName: String
    let webUrl: String
    let roles: [Roles]
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case webUrl = "url"
        case roles
    }
}

struct Roles: Codable {
    var phoneNumber: String?
    let office: String?
    let state: String?
    let party: String?
    
    private func formatPhoneNumber() -> String? {
        return self.phoneNumber?.replacingOccurrences(of: "-", with: "")
    }
    
    private enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone"
        case office
        case state
        case party
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.phoneNumber = try? valueContainer.decode(String.self, forKey: .phoneNumber)
        self.office = try? valueContainer.decode(String.self, forKey: .office)
        self.state = try? valueContainer.decode(String.self, forKey: .state)
        self.party = try? valueContainer.decode(String.self, forKey: .party)
        self.phoneNumber = formatPhoneNumber()
    }
}
