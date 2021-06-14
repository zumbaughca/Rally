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
    let screenName: String
    var blockedPosts: [String: Bool]?
    var blockedUsers: [String: Bool]?
    
    func shouldSeeContent(post: Comment) -> Bool {
        let isPostBlocked = self.blockedPosts?[post.key] != nil
        let isUserBlocked = self.blockedUsers?[post.ownerUid] != nil

        return !isPostBlocked && !isUserBlocked
    }
    
    private func setEmptyDict(_ dict: [String: Bool]?) -> [String: Bool] {
        if dict == nil {
            return [:]
        } else {
            return dict!
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case location = "ZipCode"
        case screenName = "screenname"
        case blockedPosts = "BlockedPosts"
        case blockedUsers = "BlockedUsers"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try valueContainer.decode(String.self, forKey: .name)
        self.location = try valueContainer.decode(String.self, forKey: .location)
        self.screenName = try valueContainer.decode(String.self, forKey: .screenName)
        self.blockedPosts = try? valueContainer.decode([String: Bool].self, forKey: .blockedPosts)
        self.blockedUsers = try? valueContainer.decode([String: Bool].self, forKey: .blockedUsers)
        
        self.blockedPosts = setEmptyDict(blockedPosts)
        self.blockedUsers = setEmptyDict(blockedUsers)
    }
}
