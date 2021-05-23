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
    @IBOutlet weak var logoImageView: UIImageView!
    
    let networkRequests = Network()
    let reference = Database.database().reference().child("Users")
    var bills: [Bill] = []
    var user: User?
    var adLoader: GADAdLoader!
    
    var banner: GADBannerView = {
        let banner = GADBannerView()
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            guard let displayName = user.displayName else {return}
            navigationController?.navigationBar.topItem?.title = "Welcome, \(displayName)"
            let userReference = reference.child(user.uid)
            fetchUser(userReference)
            updateUI()
        } else {
            self.returnToLoginScreen()
        }
        // AdMob Banner
        banner.rootViewController = self
        banner.adUnitID = self.stringForKey("AdMob ID")
        view.addSubview(banner)
    }
    
    // Set up Ad Mob banner view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        banner.frame = CGRect(x: 0, y: scrollView.frame.minY, width: view.frame.width, height: 50).integral
    }
    
    func updateUI() {
        let screenWidth = UIScreen.main.bounds.width

        changePasswordButton.backgroundColor = UIColor(named: self.stringForKey("Red Color")!)
        changePasswordButton.layer.cornerRadius = 15
        changePasswordButton.widthAnchor.constraint(equalToConstant: screenWidth / 2).isActive = true
        
        logoutButton.backgroundColor = UIColor(named: self.stringForKey("Red Color")!)
        logoutButton.layer.cornerRadius = 15
        logoutButton.widthAnchor.constraint(equalToConstant: screenWidth / 2).isActive = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavigationBarLogoView())
        
        logoImageView.layer.cornerRadius = 20
        logoImageView.backgroundColor = UIColor(named: "Red color")
        logoImageView.widthAnchor.constraint(equalToConstant: screenWidth / 2).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: screenWidth / 2).isActive = true
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
    
    private func returnToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginController = storyboard.instantiateViewController(identifier: "LoginController")
        self.view.window!.rootViewController = loginController
    }

    @IBAction func changePasswordButtonTapped(_ sender: Any) {
            performSegue(withIdentifier: "changePasswordSegue", sender: self)
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        networkRequests.signOutUser(completion: {[weak self] (error) in
            if error == nil {
                self?.returnToLoginScreen()
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
