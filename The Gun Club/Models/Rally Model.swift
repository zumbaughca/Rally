//
//  Rally Model.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/11/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

class Rally: Codable, Comparable, Equatable {
    
    
    let name: String
    let owner: String
    let ownerUid: String
    var date: String
    var address: String
    var longitude: Double
    var latitude: Double
    let description: String
    let key: String
    var numberOfAttendees: Int
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveUrl = documentsDirectory.appendingPathComponent("attendingRallys").appendingPathExtension("plist")

    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case owner = "Owner"
        case ownerUid = "OwnerUid"
        case date = "Date"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case description = "Description"
        case key = "Key"
        case numberOfAttendees = "NumberOfAttendees"
    }
    
    required init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try valueContainer.decode(String.self, forKey: .name)
        self.owner = try valueContainer.decode(String.self, forKey: .key)
        self.ownerUid = try valueContainer.decode(String.self, forKey: .ownerUid)
        self.date = try valueContainer.decode(String.self, forKey: .date)
        self.address = try valueContainer.decode(String.self, forKey: .address)
        self.latitude = try valueContainer.decode(Double.self, forKey: .latitude)
        self.longitude = try valueContainer.decode(Double.self, forKey: .longitude)
        self.description = try valueContainer.decode(String.self, forKey: .description)
        self.key = try valueContainer.decode(String.self, forKey: .key)
        self.numberOfAttendees = try valueContainer.decode(Int.self, forKey: .numberOfAttendees)
    }
    
    static func saveRallyAsAttending(_ rallys: [Rally]) {
        let propertyListEncoder = PropertyListEncoder()
        if let encodedRally = try? propertyListEncoder.encode(rallys) {
            try? encodedRally.write(to: archiveUrl, options: .noFileProtection)
        }
    }
    
    static func loadAttendingRallys() -> [Rally] {
        let propertyListDecoder = PropertyListDecoder()
        guard let retreivedData = try? Data(contentsOf: archiveUrl), var attendingRallys = try? propertyListDecoder.decode([Rally].self, from: retreivedData) else {return []}
        attendingRallys.forEach({
            if $0.hasRallyOccured() {
                if let index = attendingRallys.firstIndex(of: $0) {
                    attendingRallys.remove(at: index)
                }
            }
        })
        return attendingRallys
    }
    
    private func formatDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.date(from: self.date)!
    }
    
    static func < (lhs: Rally, rhs: Rally) -> Bool {
        return lhs.formatDate() < rhs.formatDate()
    }
    
    static func > (lhs: Rally, rhs: Rally) -> Bool {
        return lhs.formatDate() > rhs.formatDate()
    }
    
    static func == (lhs: Rally, rhs: Rally) -> Bool {
        return lhs.key == rhs.key
    }
    
    func hasRallyOccured() -> Bool {
        let date = Date()
        return self.formatDate() < date
    }
    
}


