//
//  NewThreadViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class NewThreadViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var threadTitleTextField: UITextField!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var newThreadLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let reference = Database.database().reference().child("Threads")
    var category: String?
    let threadModelController: ThreadModelController
    var stateController: StateController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldResignFirstResponder))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        updateUI()
    }
    
    init?(coder: NSCoder, threadModelController: ThreadModelController, category: String, stateController: StateController?) {
        self.threadModelController = threadModelController
        self.category = category
        self.stateController = stateController
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not available")
    }
    
    func updateUI() {
        postTextView.layer.borderColor = UIColor.black.cgColor
        postTextView.layer.borderWidth = 1
        postTextView.textColor = UIColor.lightGray
        newThreadLabel.text = category
        postButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    @objc func textFieldResignFirstResponder(_ sender: UITapGestureRecognizer) {
        if threadTitleTextField.isEditing {
            threadTitleTextField.resignFirstResponder()
        } else {
            postTextView.resignFirstResponder()
        }
    }
    
    func infoForKeyArray (_ key: String) -> Array<String>? {
        return (Bundle.main.infoDictionary?[key] as? Array)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
            textView.text = nil
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
      }
    
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
    
    @IBAction func save(_ sender: Any) {
        do {
            try threadTitleTextField.validatePostTitleIsValid()
            postTextView.removePlaceholderText(text: "Enter your post here...")
            try postTextView.validateIsNotEmpty()
            try threadTitleTextField.validateIsNotEmpty(with: TextFieldValidationError.postTitleIsEmpty)
            threadModelController.createNewPost(title: threadTitleTextField.text!, post: postTextView.text!, category: category!)
            dismiss(animated: true, completion: nil)
        } catch {
            self.createErrorAlert(for: error.localizedDescription)
        }
    }

}
