//
//  LoginViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/4/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var registerLabels: [UILabel]!
    @IBOutlet var registerTextFields: [UITextField]!
    @IBOutlet weak var registerStackView: UIStackView!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerAgeSwitch: UISwitch!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIForLogin()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewEndEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        loginRegisterButton.backgroundColor = UIColor(named: "pastelBlue")
        loginRegisterButton.layer.cornerRadius = 15
        contentView.backgroundColor = UIColor(named: "pastelRed")
    }
    
    func configureUIForLogin() {
        registerLabels.forEach({
            $0.isHidden = true
            $0.isEnabled = false
        })
        registerTextFields.forEach({
            $0.isHidden = true
            $0.isEnabled = false
        })
        
        registerStackView.isHidden = true
        loginRegisterButton.setTitle("Login", for: .normal)
    }
    
    func configureUIForRegister() {
        registerLabels.forEach({
            $0.isHidden = false
            $0.isEnabled = true
        })
        
        registerTextFields.forEach({
            $0.isHidden = false
            $0.isEnabled = true
        })
        
        registerStackView.isHidden = false
        loginRegisterButton.setTitle("Register", for: .normal)
    }
    
    // Sign in with Firebase
    func signIn() {
     if let email = emailTextField.text,
            let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
                if error != nil {
                    self.createErrorAlert(for: error!.localizedDescription)
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
    
    /*
     * First make sure the password fields match.
     * Then get the values for each text field and ensure the user is over 18.
     * Then create a new user in Firebase
     */
    func registerNewUser() {
        if passwordTextField.text == confirmPasswordTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let zipCode = zipCodeTextField.text, let name = nameTextField.text,
            let displayName = screenNameTextField.text{
            if registerAgeSwitch.isOn {
                Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
                    if error != nil {
                        self.createErrorAlert(for: error!.localizedDescription)
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
                self.createErrorAlert(for: "You must be 18 years of age or older to use this app.")
            }
        } else {
            //Passwords do not match
            self.createErrorAlert(for: "Passwords do not match.")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    
    @objc func textViewEndEditing() {
        currentTextField?.resignFirstResponder()
    }
    
    /*
     * When the user starts to edit a text field the view needs to shift to
     * accomadate the text field. If it is in the way, scroll the view up, otherwise leave it
     * alone. When the text field resigns first responder, reset the view to normal.
     */
    @objc func keyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {return}
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else {
            self.scrollView.contentInset = UIEdgeInsets.zero
            self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    @IBAction func loginRegisterSelectorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            configureUIForLogin()
        case 1:
            configureUIForRegister()
        default:
            configureUIForLogin()
        }
    }
    
    /*
     * If the button text is login, then the user is trying to log in.
     * If it is register, then we need to register a new user in the system.
     */
    @IBAction func loginRegisterButtonPressed(_ sender: UIButton) {
        if sender.titleLabel!.text == "Login" {
            signIn()
        } else if sender.titleLabel!.text == "Register" {
            registerNewUser()
        }
    }
}