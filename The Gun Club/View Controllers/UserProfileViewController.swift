//
//  UserProfileViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/5/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, Observer {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var screenNameTitleLabel: UILabel!
    
    let networkRequests = Network()
    let reference = Database.database().reference().child("Users")
    var user: User? {
        didSet {
            updateUser()
        }
    }
    var adLoader: GADAdLoader!
    var stateController: StateController?
    
    var banner: GADBannerView = {
        let banner = GADBannerView()
        banner.load(GADRequest())
        banner.backgroundColor = .secondarySystemBackground
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Loading..."
        screenNameLabel.text = "Loading..."
        
        // AdMob Banner
        banner.rootViewController = self
        banner.adUnitID = self.stringForKey("AdMob ID")
        view.addSubview(banner)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stateController?.observer = self
        if stateController?.inProgress == false && stateController?.getCurrentUser() == nil {
            updateUI()
            updateUIForGuest()
        } else {
            dataDidUpdate()
        }
    }
    
    // Set up Ad Mob banner view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        banner.frame = CGRect(x: 0, y: scrollView.frame.minY, width: view.frame.width, height: 50).integral
    }
    
    func dataDidUpdate() {
        user = stateController?.getCurrentUser()
        updateUser()
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
    
    func updateUIForGuest() {
        navigationController?.navigationBar.topItem?.title = "Welcome, Guest"
        nameLabel.isHidden = true
        nameTitleLabel.isHidden = true
        screenNameTitleLabel.isHidden = true
        screenNameLabel.text = "You are currently using Rally as a guest. Some functionality, such as contributing on the forum, may be disabled. For full functionality, please create an account."
        changePasswordButton.isHidden = true
        logoutButton.setTitle("Create an account", for: .normal)
    }

    func updateUser() {
        if let user = user {
            let displayName = user.screenName
            navigationController?.navigationBar.topItem?.title = "Welcome, \(displayName)"
            nameLabel.text = user.name
            screenNameLabel.text = user.screenName
            updateUI()
        } else {
            updateUI()
            updateUIForGuest()
        }
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
        let loginController = storyboard.instantiateViewController(identifier: "LoginController") as LoginViewController
        loginController.stateController = stateController
        self.view.window!.rootViewController = loginController
    }

    @IBAction func changePasswordButtonTapped(_ sender: Any) {
            performSegue(withIdentifier: "changePasswordSegue", sender: self)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        networkRequests.signOutUser(completion: {[weak self] (error) in
            self?.returnToLoginScreen()
        })
    }

}
