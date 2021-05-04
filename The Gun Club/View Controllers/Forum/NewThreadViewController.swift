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
    
    let reference = Database.database().reference().child("Threads")
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldResignFirstResponder))
        self.view.addGestureRecognizer(tapGesture)
        updateUI()
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
    
    @IBAction func save(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: Date())
        if let title = threadTitleTextField.text,
            let post = postTextView.text,
            let category = category{
            if let user = Auth.auth().currentUser {
                let newPostReference = reference.child(category).childByAutoId()
                newPostReference.updateChildValues(["Title": title, "Date": date, "Owner": user.displayName!, "OwnerUid": user.uid, "Category": category, "NumberOfComments": 0, "Post": post, "Key": newPostReference.key!, "LastActivity": date, "Locked": false])
            }
        }
        dismiss(animated: true, completion: nil)
    }

}
