//
//  Background Fetch.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 9/1/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import Firebase

class BackgroundRefreshOperation: Operation {
    
    var rallys: [Rally]
    let firebaseRequests: FirebaseRequests
    
    init(rallys: [Rally], requests: FirebaseRequests) {
        self.rallys = rallys
        self.firebaseRequests = requests
    }
    
    override func main() {
        if isCancelled {
            return
        }
        firebaseRequests.observeChildAdded(reference: Database.database().reference().child("Rallys"), completion: {(rally: Rally?, error) in
            if let rally = rally {
                self.rallys.append(rally)
                print(self.rallys)
            }
        })
        
        if isCancelled {
            return
        }
        
        if !rallys.isEmpty {
            
        }
    }
}
