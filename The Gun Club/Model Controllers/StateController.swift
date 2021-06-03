//
//  StateController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 6/2/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import Firebase

class StateController: Observable {
    
    private var user: User?
    private var networkModule: Network
    weak var observer: Observer?
    
    func getCurrentUser() -> User? {
        return user
    }
    
    internal func notifyObserver() {
        observer?.dataDidUpdate()
    }
    
    func fetchUser(_ reference: DatabaseReference) {
        networkModule.queryUserName(reference: reference, completion: {[unowned self] (user, error) in
            if let user = user {
                self.user = user
                notifyObserver()
            }
        })
    }
    
    init(networkModule: Network) {
        self.networkModule = networkModule
    }
}
