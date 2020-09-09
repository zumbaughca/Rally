//
//  LoginTableViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/14/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class LoginTableViewController: UITableViewController {
    
    @IBOutlet weak var registerTableViewCell: UITableViewCell!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var registerNameTextField: UITextField!
    @IBOutlet weak var registerScreenNameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var registerConfirmPasswordTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    @IBOutlet weak var registerConfirmAgeSwitch: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        updateUI()
    }
    
    func updateUI() {
        loginPasswordTextField.isSecureTextEntry = true
        registerPasswordTextField.isSecureTextEntry = true
        registerConfirmPasswordTextField.isSecureTextEntry = true
        registerStackView.isHidden = true
        loginRegisterSegmentedControl.setTitle("Login", forSegmentAt: 0)
        loginRegisterSegmentedControl.setTitle("Register", forSegmentAt: 1)
    }
    
    func signIn() {
     if let email = loginEmailTextField.text,
            let password = loginPasswordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
                if error != nil {
                    let alertController = UIAlertController()
                    alertController.message = error?.localizedDescription
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                if authResult != nil {
                 if (authResult?.user) != nil {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                        self.view.window!.rootViewController = tabBarController
                    }
                }
            })
        }
    }
    
    func registerNewUser() {
        if registerPasswordTextField.text == registerConfirmPasswordTextField.text,
            let email = registerEmailTextField.text,
            let password = registerPasswordTextField.text,
            let zipCode = zipCodeTextField.text, let name = registerNameTextField.text,
            let displayName = registerScreenNameTextField.text{
            if registerConfirmAgeSwitch.isOn {
                Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
                    if error != nil {
                        let alertController = UIAlertController()
                        alertController.message = error?.localizedDescription
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    if let authResult = authResult {
                        let user = authResult.user
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        let database = Database.database().reference()
                        database.child("Users").child(user.uid).updateChildValues(["ZipCode": zipCode])
                        database.child("Users").child(user.uid).updateChildValues(["Name": name])
                        changeRequest.commitChanges(completion: {error in
                            if error == nil {
                                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                                self.view.window!.rootViewController = tabBarController
                            }
                        })
                    }
                })
            } else {
                //User is not 18
                let alertController = UIAlertController()
                alertController.message = "You must be 18 years of age or older to use this app."
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
            }
        } else {
            //Passwords do not match
            let alertController = UIAlertController()
            alertController.message = "Passwords do not match."
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 250
        case 1:
            if loginStackView.isHidden {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        case 2:
            if registerStackView.isHidden {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    @IBAction func loginRegisterSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            loginStackView.isHidden = true
            registerStackView.isHidden = false
            tableView.reloadData()
        default:
            loginStackView.isHidden = false
            registerStackView.isHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        signIn()
    }
    @IBAction func registerButtonPressed(_ sender: Any) {
        registerNewUser()
    }
    
}
