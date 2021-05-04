//
//  ProfileViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/13/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//
import UIKit
import Firebase

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableViewFooter: UIView!
    
    let networkRequests = Network()
    let reference = Database.database().reference().child("Users")
    var bills: [Bill] = []
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            guard let displayName = user.displayName else {return}
            navigationController?.navigationBar.topItem?.title = "Welcome, \(displayName)"
            let userReference = reference.child(user.uid)
            fetchUser(userReference)
        }
        self.tableView.tableFooterView = tableViewFooter
    }
    
    func fetchUser(_ reference: DatabaseReference) {
        networkRequests.queryUserName(reference: reference, completion: {[weak self] (user, error) in
            guard let self = self else {return}
            if let user = user {
                self.user = user
                self.updateUI(user)
            }
        })
    }
    
    func updateUI(_ user: User) {
        nameLabel.text = user.name
        screenNameLabel.text = Auth.auth().currentUser?.displayName
        locationLabel.text = user.location
    }
    
    func presentLogoutErrorAlert() {
        let alertController = UIAlertController(title: "Error logging out", message: "We could not log you out at this time. Please try again later.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {

    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        networkRequests.signOutUser(completion: {[weak self] (error) in
            if error == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let loginController = storyboard.instantiateViewController(identifier: "LoginController")
                self?.view.window!.rootViewController = loginController
            } else {
                self?.presentLogoutErrorAlert()
            }
        })
    }
}
