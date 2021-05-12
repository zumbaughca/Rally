//
//  UpdatePasswordViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/5/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var updateCredentialsStackView: UIStackView!
    @IBOutlet weak var changePasswordStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var updateCredentialButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    var credential: AuthCredential?
    let errorTitle = "There was an error changing your password"
    var currentTextField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCredentialsStackView.isHidden = true
        updateUI()
    }
    
    func updateUI() {
        scrollView.backgroundColor = UIColor(named: self.stringForKey("Red Color")!)
        contentView.backgroundColor = UIColor(named: self.stringForKey("Red Color")!)
        
        updateCredentialButton.backgroundColor = UIColor(named: self.stringForKey("Blue Color")!)
        changePasswordButton.backgroundColor = UIColor(named: self.stringForKey("Blue Color")!)
        updateCredentialButton.layer.cornerRadius = 15
        changePasswordButton.layer.cornerRadius = 15
        
        oldPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        confirmNewPasswordTextField.isSecureTextEntry = true
    }
    
    func presentRequestCredentialView() {
        changePasswordStackView.isHidden = true
        updateCredentialsStackView.isHidden = false
    }
    
    func reauthenticateUser() {
        guard let email = emailTextField.text, let password = oldPasswordTextField.text else {return}
        credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().signIn(with: credential!, completion: {(authResult, error) in
            if error == nil {
                self.changePasswordStackView.isHidden = false
                self.updateCredentialsStackView.isHidden = true
                self.changePassword()
            }
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidCredential:
                    self.createAlert(self.errorTitle, "The username or password is incorrect.", successAlert: false)
                default:
                    self.createAlert(self.errorTitle, error.localizedDescription, successAlert: false)
                }
            }
        })
    }
    
    func createAlert(_ title: String, _ message: String, successAlert: Bool) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {(cancelAction) in
            if successAlert == true {
                self.dismiss(animated: true, completion: nil)
            }
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func changePassword() {
        guard newPasswordTextField.text == confirmNewPasswordTextField.text else {return}
        if let newPassword = newPasswordTextField.text {
            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: {(error) in
                if error == nil {
                    self.createAlert("Your password was changed successfully.", "", successAlert: true)
                } else {
                    if let error = error as NSError? {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .userDisabled:
                            self.createAlert(self.errorTitle, "The user has been disabled by an administrator.", successAlert: false)
                        case .weakPassword:
                            self.createAlert(self.errorTitle, "The new password must be at least 6 characters long.", successAlert: false)
                        case .operationNotAllowed:
                            self.createAlert(self.errorTitle, "Password changes have been disabled by the administrator.", successAlert: false)
                        case .requiresRecentLogin:
                            self.createAlert(self.errorTitle, "You must have signed in recently. Please provide your login credentials.", successAlert: false)
                            self.presentRequestCredentialView()
                        default:
                            self.createAlert(self.errorTitle, error.localizedDescription, successAlert: false)
                        }
                    }
                }
            })
        }
    }

    
    @IBAction func reauthenticateButtonPressed(_ sender: Any) {
        reauthenticateUser()
    }
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        changePassword()
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
