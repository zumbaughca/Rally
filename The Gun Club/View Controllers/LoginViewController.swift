//
//  LoginViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/4/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    deinit {
        print("Login deinit")
    }

    @IBOutlet var registerLabels: [UILabel]!
    @IBOutlet var registerTextFields: [UITextField]!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerAgeSwitch: UISwitch!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var eulaButton: UIButton!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    
    weak var currentTextField: UITextField?
    let network = Network()
    var stateController: StateController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIForLogin()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewEndEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        styleButton(loginRegisterButton)
        styleButton(continueAsGuestButton)
        styleButton(eulaButton)
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
    }
    
    private func navigateToHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController") as TabBarViewController
        tabBarController.stateController = stateController
        self.view.window!.rootViewController = tabBarController
    }
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor(named: "pastelBlue")
        button.layer.cornerRadius = 15
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
        let selectedIndex = loginRegisterSegmentedControl.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            signIn()
        case 1:
            //validateAndRegister()
            presentEULA()
        default:
            fatalError("Selected index out of bounds")
        }
    }
    
    @IBAction func continueAsGuestButtonPressed(_ sender: Any) {
        navigateToHomeVC()
    }
    
    // Present the apps EULA in Safari View Controller
    @IBAction func viewEULAButtonTapped(_ sender: Any) {
        guard let url = URL(string: self.stringForKey("EULA URL")!) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    
}

//MARK: Text Field and Keyboard methods
extension LoginViewController {
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
}

// MARK: Registration validation
extension LoginViewController {
    
    private func validateRegistration() throws {
        do {
            try nameTextField.validateIsNotEmpty(with: RegistrationErrors.noNameProvided)
            try screenNameTextField.validateIsNotEmpty(with: RegistrationErrors.noScreenNameProvided)
            try emailTextField.validateIsNotEmpty(with: RegistrationErrors.noEmailProvided)
            try zipCodeTextField.validateIsNotEmpty(with: RegistrationErrors.noZipCodeProvided)
            if passwordTextField.text != confirmPasswordTextField.text {
                throw RegistrationErrors.passwordsDoNotMatch
            }
        }
    }
}

// MARK: Sign in and User Registration
extension LoginViewController {
    
    func createLoadingAlert() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        self.view.isUserInteractionEnabled = false
        present(alert, animated: true, completion: nil)
    }
    // Sign in with Firebase
    func signIn() {
     if let email = emailTextField.text,
            let password = passwordTextField.text {
        createLoadingAlert()
            Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self ] (authResult, error) in
                if error != nil {
                    self?.createErrorAlert(for: "Either the password is incorrect or this user does not have an account.")
                }
                if authResult != nil {
                 if (authResult?.user) != nil {
                    self?.navigateToHomeVC()
                    }
                }
            })
        }
    }
    
    /*
     * First validate the form.
     * Then ensure the screen name doesn't already exist.
     * Then complete the registration
     */
    private func validateAndRegister() {
        do {
            createLoadingAlert()
            try validateRegistration()
            network.validateUsername(screenNameTextField.text!, completion: {[weak self] (error, bool) in
                if let _ = error {
                    self?.createErrorAlert(for: RegistrationErrors.unknownError.localizedDescription)
                    return
                }
                if bool == true {
                    self?.registerNewUser()
                } else {
                    self?.createErrorAlert(for: RegistrationErrors.screenNameAlreadyExists.localizedDescription)
                }
            })
        } catch {
            self.createErrorAlert(for: error.localizedDescription)
        }
    }
    
    func presentEULA() {
        let alertController = UIAlertController(title: "End User License Agreement", message: "By clicking accept you agree to the terms of our EULA", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Accept", style: .default, handler: {[unowned self] action in
            self.validateAndRegister()
        })
        let declineAction = UIAlertAction(title: "Decline", style: .cancel, handler: nil)
        let viewAction = UIAlertAction(title: "View", style: .default, handler: {[unowned self] action in
            let url = URL(string: self.stringForKey("EULA URL")!)!
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        })
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        alertController.addAction(viewAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     * Then get the values for each text field and ensure the user is over 18.
     * Then create a new user in Firebase
     */
    func registerNewUser() {
        if let email = emailTextField.text,
           let password = passwordTextField.text,
           let zipCode = zipCodeTextField.text,
           let name = nameTextField.text,
           let displayName = screenNameTextField.text{
            if registerAgeSwitch.isOn {
                network.registerUserAndAddToDatabase(email: email, password: password, zipCode: zipCode, name: name, displayName: displayName, completion: {[weak self](error) in
                    if let error = error {
                        self?.createErrorAlert(for: error.localizedDescription)
                    } else {
                        self?.navigateToHomeVC()
                    }
                })
            } else {
                //User is not 18
                self.createErrorAlert(for: "You must be 18 years of age or older to use this app.")
            }
        }
    }
}
