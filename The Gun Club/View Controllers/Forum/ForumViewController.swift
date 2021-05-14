//
//  ForumViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class ForumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splashScreen: UIView!
    @IBOutlet weak var splashScreenActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var contentView: UIView!
    
    var threads: [ForumThread] = []
    var first: ForumThread?
    let reference = Database.database().reference().child("Threads")
    var isStartup = true
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = selectedCategory
        self.navigationItem.titleView = NavigationBarLogoView()
        tableView.isHidden = true
        splashScreen.isHidden = false
        splashScreenActivityIndicator.style = .large
        splashScreenActivityIndicator.startAnimating()
        fetchThreads()
    }
    
    func contentHasLoaded() {
        splashScreenActivityIndicator.stopAnimating()
        splashScreen.isHidden = true
        tableView.isHidden = false
    }
    
    func fetchThreads() {
        guard let selectedCategory = selectedCategory else {return}
        let firebaseRequests = Network()
        firebaseRequests.observeChildAdded(reference: reference.child(selectedCategory), completion: {[weak self] (thread: ForumThread?, error) in
            guard let self = self else {return}
            if error != nil {
                //Handle error
                DispatchQueue.main.async {
                    self.contentHasLoaded()
                }
            }
            if let thread = thread {
                thread.comments = []
                if !self.threads.contains(thread) {
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
                self.contentHasLoaded()
                self.tableView.reloadData()
            }
        })
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return threads.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "readme")!
            cell.textLabel?.text = first?.title
            cell.detailTextLabel?.text = "New users please read this before posting"
            return cell
        } else {
            let thread = threads[indexPath.row]
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "forumPost")!
            cell.textLabel?.text = thread.title
            cell.detailTextLabel?.text = "Last post: \(thread.lastActivityTime)"
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "threadSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            let thread = threads[indexPath.row]
            let destinationViewController = segue.destination as? ThreadViewController
            destinationViewController?.thread = thread
        }
        if segue.identifier == "showReadme" {
            let destinationViewController = segue.destination as? ThreadViewController
            destinationViewController?.thread = first
        }
        if segue.identifier == "newThreadSegue" {
            let destinationViewController = segue.destination as? NewThreadViewController
            destinationViewController?.category = selectedCategory
        }
    }
    
}
