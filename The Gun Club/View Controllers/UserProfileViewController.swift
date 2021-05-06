//
//  UserProfileViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/5/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
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
            updateUI()
        }
    }
    
    func updateUI() {
        scrollView.backgroundColor = UIColor(named: self.stringForKey("Background Color")!)
        contentView.backgroundColor = UIColor(named: self.stringForKey("Background Color")!)
        changePasswordButton.backgroundColor = UIColor(named: self.stringForKey("Blue Color")!)
        changePasswordButton.layer.cornerRadius = 15
        logoutButton.backgroundColor = UIColor(named: self.stringForKey("Blue Color")!)
        logoutButton.layer.cornerRadius = 15
        navigationController?.navigationBar.barTintColor = UIColor(named: self.stringForKey("Background Color")!)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
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
    }
    
    func presentLogoutErrorAlert() {
        let alertController = UIAlertController(title: "Error logging out", message: "We could not log you out at this time. Please try again later.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}