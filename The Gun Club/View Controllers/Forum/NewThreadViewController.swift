//
//  NewThreadViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/24/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class NewThreadViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    @IBOutlet weak var threadTitleTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var postTextView: UITextView!
    
    let reference = Database.database().reference().child("Threads")
    var categories: [String] = []
    var category: String = "Pistol"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.postTextView.delegate = self
        postTextView.layer.borderColor = UIColor.black.cgColor
        postTextView.layer.borderWidth = 1
        postTextView.textColor = UIColor.lightGray
        categories = infoForKeyArray("Categories")!
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldResignFirstResponder))
        self.view.addGestureRecognizer(tapGesture)
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
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
      }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category = categories[row]
        print(category)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    @IBAction func save(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: Date())
        if let title = threadTitleTextField.text,
            let post = postTextView.text{
            if let user = Auth.auth().currentUser {
                let newPostReference = reference.child(category).childByAutoId()
                newPostReference.updateChildValues(["Title": title, "Date": date, "Owner": user.displayName!, "OwnerUid": user.uid, "Category": category, "NumberOfComments": 0, "Post": post, "Key": newPostReference.key!, "LastActivity": date, "Locked": false])
            }
        }
        dismiss(animated: true, completion: nil)
    }

}
