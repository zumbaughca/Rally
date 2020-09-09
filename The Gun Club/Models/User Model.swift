//
//  User Model.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/26/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

final class User: Codable {
    var name: String
    var location: String
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case location = "ZipCode"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try valueContainer.decode(String.self, forKey: .name)
        self.location = try valueContainer.decode(String.self, forKey: .location)
    }
}
