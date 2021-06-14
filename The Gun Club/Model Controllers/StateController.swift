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
    private var uid: String?
    private var moderators: [String]
    private var networkModule: Network
    weak var observer: Observer?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    var inProgress = true
    
    func getCurrentUser() -> User? {
        return user
    }
    
    func isUserModerator() -> Bool {
        guard let uid = uid else { return false }
        if moderators.contains(uid) {
            return true
        } else {
            return false
        }
    }
    
    internal func notifyObserver() {
        observer?.dataDidUpdate()
    }
    
    func attachListner() {
        setNullUser()
        self.authStateListener = Auth.auth().addStateDidChangeListener({[unowned self] (auth, user) in
            if let user = user {
                inProgress = true
                let reference = Database.database().reference().child("Users")
                self.uid = user.uid
                self.networkModule.queryUserName(reference: reference.child(user.uid), completion: {[unowned self] (user, error) in
                    self.inProgress = false
                    if let user = user {
                        self.user = user
                        self.observer?.dataDidUpdate()
                    }
                })
            } else {
                self.user = nil
                self.observer?.dataDidUpdate()
            }
        })
    }
    
    private func setNullUser() {
        if Auth.auth().currentUser == nil {
            inProgress = false
            self.observer?.dataDidUpdate()
        }
    }
        
    func reportUser(of post: Comment) {
        Database.database().reference().child("ReportedUsers").child(post.ownerUid).updateChildValues([post.owner: post.post])
    }
    
    func blockUser(of post: Comment) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("BlockedUsers").updateChildValues([post.ownerUid: true])
            user?.blockedUsers?[post.ownerUid] = true
    }
    
    func blockPost(of post: Comment) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("BlockedPosts").updateChildValues([post.key: true])
            user?.blockedPosts?[post.key] = true
        
    }
    
    // Get a list of the moderators when the thread is loaded.
    private func fetchModerators() {
        networkModule.queryModerators(completion: {[weak self] (moderators, error) in
            guard let self = self else {return}
            if let moderators = moderators {
                print(moderators)
                self.moderators = moderators
            }
        })
    }
    
    init(networkModule: Network) {
        self.networkModule = networkModule
        self.moderators = []
        fetchModerators()
    }
    
    deinit {
        if authStateListener != nil {
            Auth.auth().removeStateDidChangeListener(authStateListener!)
        }
    }
}
