//
//  ChangePasswordViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var requestCredentialStackView: UIStackView!
    @IBOutlet weak var changePasswordStackView: UIStackView!
    @IBOutlet weak var emailCredentialTextField: UITextField!
    @IBOutlet weak var requestCredentialPasswordTextField: UITextField!
    
    var credential: AuthCredential?
    let errorTitle = "There was an error changing your password"

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCredentialStackView.isHidden = true
    }
    
    func presentRequestCredentialView() {
        changePasswordStackView.isHidden = true
        requestCredentialStackView.isHidden = false
    }
    
    func reauthenticateUser() {
        guard let email = emailCredentialTextField.text, let password = requestCredentialPasswordTextField.text else {return}
        credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().signIn(with: credential!, completion: {(authResult, error) in
            if error == nil {
                self.changePasswordStackView.isHidden = false
                self.requestCredentialStackView.isHidden = true
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

    @IBAction func submitButtonPressed(_ sender: Any) {
        changePassword()
    }
    
    @IBAction func reauthenticateSubmitButtonPressed(_ sender: Any) {
        reauthenticateUser()
    }
}
