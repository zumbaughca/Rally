//
//  ForumViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class ForumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Observer {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splashScreen: UIView!
    @IBOutlet weak var splashScreenActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var contentView: UIView!
    
    let reference = Database.database().reference().child("Threads")
    var selectedCategory: String
    var user: User?
    var threadModelController: ThreadModelController
    let networkRequests = Network()
    
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
        threadModelController.observer = self

        
        if let user = Auth.auth().currentUser {
            fetchUser(Database.database().reference().child("Users").child(user.uid), completion: {[unowned self] user in
                self.user = user
                print(user?.blockedUsers)
                threadModelController.fetchThreads(for: self.user, at: reference, in: selectedCategory)
            })
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    init?(coder: NSCoder, category: String, threadModelController: ThreadModelController, user: User?) {
        self.selectedCategory = category
        self.threadModelController = threadModelController
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func dataDidUpdate() {
        self.contentHasLoaded()
        tableView.reloadData()
    }
    
    func contentHasLoaded() {
        splashScreenActivityIndicator.stopAnimating()
        splashScreen.isHidden = true
        tableView.isHidden = false
    }
    
    func fetchUser(_ reference: DatabaseReference, completion: @escaping (_ user: User?) -> Void) {
        networkRequests.queryUserName(reference: reference, completion: {(user, error) in
            if let user = user {
                completion(user)
            } else {
                completion(nil)
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
            return threadModelController.threadCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showReadme", sender: nil)
        case 1:
            performSegue(withIdentifier: "threadSegue", sender: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "readme")!
            cell.textLabel?.text = threadModelController.first?.title
            cell.detailTextLabel?.text = "New users please read this before posting"
            return cell
        } else {
            let thread = threadModelController.getThread(at: indexPath.row)
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "forumPost")!
            cell.textLabel?.text = thread?.title
            cell.detailTextLabel?.text = "Last post: \(thread?.lastActivityTime ?? "")"
            return cell
        }
    }
    
    @IBAction func newThreadButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "newThreadSegue", sender: nil)
    }
    
    @IBSegueAction
    func show(coder: NSCoder, sender: Any?, segueIdentifier: String) -> UIViewController? {
        if segueIdentifier == "threadSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            let thread = threadModelController.getThread(at: indexPath.row)!
            return ThreadViewController(coder: coder, threadModelController: ThreadModelController(networkModule: Network(), observer: nil, currentUser: nil), thread: thread)
        }
        if segueIdentifier == "showReadme" {
            let thread = threadModelController.first!
            return ThreadViewController(coder: coder, threadModelController: ThreadModelController(networkModule: Network(), observer: nil, currentUser: nil), thread: thread)
        }
        if segueIdentifier == "newThreadSegue" {
            return NewThreadViewController(coder: coder, threadModelController: ThreadModelController(networkModule: Network(), observer: nil, currentUser: nil), category: self.selectedCategory)
        }
        return nil
    }

    
}
