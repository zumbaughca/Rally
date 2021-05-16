//
//  Thread Model.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

class Comment: Codable, Equatable {
    let post: String
    let date: String
    let owner: String
    let ownerUid: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case post = "Post"
        case date = "Date"
        case owner = "Owner"
        case ownerUid = "OwnerUid"
        case key = "Key"
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.key == rhs.key
    }
    
    required init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.post = try valueContainer.decode(String.self, forKey: .post)
        self.date = try valueContainer.decode(String.self, forKey: .date)
        self.owner = try valueContainer.decode(String.self, forKey: .owner)
        self.ownerUid = try valueContainer.decode(String.self, forKey: .ownerUid)
        self.key = try valueContainer.decode(String.self, forKey: .key)
    }
}

class ForumThread: Comment, Comparable {
    let title: String
    let category: String
    var lastActivityTime: String
    var numberOfComments: Int = 0
    var locked: Bool
    var comments: [Comment]?
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case category = "Category"
        case lastActivityTime = "LastActivity"
        case comments = "Comments"
        case locked = "Locked"
    }
    
    private func createTimestampFromDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.date(from: self.lastActivityTime)!
    }
    
    static func < (lhs: ForumThread, rhs: ForumThread) -> Bool {
        return lhs.createTimestampFromDate() < rhs.createTimestampFromDate()
    }
    
    static func > (lhs: ForumThread, rhs: ForumThread) -> Bool {
        return lhs.createTimestampFromDate() > rhs.createTimestampFromDate()
    }
    
    required init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try valueContainer.decode(String.self, forKey: .title)
        self.category = try valueContainer.decode(String.self, forKey: .category)
        self.lastActivityTime = try valueContainer.decode(String.self, forKey: .lastActivityTime)
        self.comments = try? valueContainer.decode([Comment].self, forKey: .comments)
        self.locked = try valueContainer.decode(Bool.self, forKey: .locked)
        try super.init(from: decoder)
    }
}
