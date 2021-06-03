//
//  ThreadModelController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 6/2/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import Firebase

class ThreadModelController: Observable {
    private var threads: [ForumThread] = []
    private (set) var first: ForumThread?
    private let networkModule: Network
    weak var observer: Observer?
    weak var currentUser: User?
    
    var threadCount: Int {
        return threads.count
    }
    
    func getThreads() -> [ForumThread] {
        return threads
    }
    
    func getThread(at index: Int) -> ForumThread? {
        guard index < threadCount else { return nil }
        return threads[index]
    }
    
    internal func notifyObserver() {
        observer?.dataDidUpdate()
    }
    
    func fetchThreads(for user: User?, at reference: DatabaseReference, in category: String) {
        networkModule.observeChildAdded(reference: reference.child(category), completion: {[weak self] (thread: ForumThread?, error) in
            guard let self = self else {return}
            if error != nil {
                //Handle error
                DispatchQueue.main.async {
                    
                }
            }
            if let thread = thread {
                thread.comments = []
                let userShouldSee = user?.shouldSeeContent(post: thread) ?? true
                if !self.threads.contains(thread) && userShouldSee {
                    if thread.title == "README" {
                        self.first = thread
                    } else {
                        if let insertIndex = self.threads.firstIndex(where: {$0 < thread}) {
                            self.threads.insert(thread, at: insertIndex)
                        } else {
                            self.threads.append(thread)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.notifyObserver()
            }
        })
    }
    
    func fetchThreadComments(for user: User?, of thread: ForumThread, at reference: DatabaseReference) {
        networkModule.observeChildAdded(reference: reference.child(thread.key), completion: {[weak self] (comment: Comment?, error) in
            guard let self = self else {return}
            if let comment = comment {
                let userShouldSee = user?.shouldSeeContent(post: comment) ?? true
                if !(thread.comments?.contains(comment) ?? false) && userShouldSee {
                    thread.comments?.append(comment)
                    DispatchQueue.main.async {
                        self.notifyObserver()
                    }
                }
            }
        })
    }
    
    func postComment(_ text: String, thread: ForumThread) {
        let threadReference = Database.database().reference().child("Threads")
        let date = DateFormatter().getFormattedStringFromCurrentDate()
        if let user = Auth.auth().currentUser {
            let commentRef = Database.database().reference().child("Comments").child(thread.key).childByAutoId()
            commentRef.updateChildValues(["Post": text, "Owner": user.displayName!, "OwnerUid": user.uid, "Date": date, "Key": commentRef.key!])
            threadReference.updateChildValues(["LastActivity": date])
            Database.database().reference().child("Users").child(user.uid).child("Comments").child(thread.category).child(thread.key).updateChildValues([commentRef.key!: date])
        }
    }
    
    func createNewPost(title: String, post: String, category: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: Date())
        if let user = Auth.auth().currentUser {
            let newPostReference = Database.database().reference().child("Threads").child(category).childByAutoId()
            newPostReference.updateChildValues(["Title": title, "Date": date, "Owner": user.displayName!, "OwnerUid": user.uid, "Category": category, "Post": post, "Key": newPostReference.key!, "LastActivity": date, "Locked": false])
            Database.database().reference().child("Users").child(user.uid).child("Posts").child(category).updateChildValues([newPostReference.key!: dateFormatter.string(from: Date())])
        }
    }

    
    init(networkModule: Network, observer: Observer?, currentUser: User?) {
        self.networkModule = networkModule
        self.observer = observer
        self.currentUser = currentUser
    }
}
