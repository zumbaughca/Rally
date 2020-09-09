//
//  ThreadViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class ThreadViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var threadLockedButton: UIBarButtonItem!
    @IBOutlet weak var postCommentButton: UIButton!
    
    var thread: Thread?
    var moderators: [String]?
    let reference = Database.database().reference().child("Threads")
    let firebaseRequests = FirebaseRequests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchModerators()
        fetchThreadComments()
        self.commentTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tableView.register(MainPostTableViewCell.self, forCellReuseIdentifier: "mainPost")
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "comment")

        setTextFieldPlaceholderText()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewEndEditing))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        updateUI()
        fetchLockedStatus()
    }
    
    func updateUI() {
        guard let user = Auth.auth().currentUser, let thread = thread else {return}
        tableView.separatorStyle = .none
        commentTextField.layer.borderColor = UIColor.black.cgColor
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.cornerRadius = 15
        commentTextField.isScrollEnabled = false
        commentTextField.textContainer.heightTracksTextView = true
        if user.uid != thread.ownerUid {
            threadLockedButton.isEnabled = false
        }
        if thread.locked == false {
            threadLockedButton.image = UIImage(systemName: "lock.open.fill")
        } else {
            threadLockedButton.image = UIImage(systemName: "lock.fill")
        }
        threadLockedStatusDidChange()
    }
    
    func allowModeratorPrivileges() {
        guard let user = Auth.auth().currentUser, let moderators = moderators else {return}
        if moderators.contains(user.uid) {
            threadLockedButton.isEnabled = true
        }
    }
    
    func fetchModerators() {
        firebaseRequests.queryModerators(completion: {(moderators, error) in
            if let moderators = moderators {
                self.moderators = moderators
                DispatchQueue.main.async {
                    self.allowModeratorPrivileges()
                }
            }
        })
    }
    
    func fetchLockedStatus() {
        guard let thread = thread else {return}
        firebaseRequests.observeThreadLockedStatus(reference: reference.child(thread.category).child(thread.key).child("Locked"), completion: {(bool, error) in
            if let bool = bool {
                self.thread!.locked = bool
                self.threadLockedStatusDidChange()
            }
        })
    }
    
    func threadLockedStatusDidChange() {
        if thread!.locked == true {
            commentTextField.isEditable = false
            postCommentButton.isEnabled = false
            commentTextField.text = "This thread is locked."
        } else if thread!.locked == false {
            commentTextField.isEditable = true
            postCommentButton.isEnabled = true
            commentTextField.text = "New comment..."
        }
    }
    
    func adjustTextViewHeight() {
        let width = commentTextField.frame.width
        let adjustedSize = commentTextField.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        commentTextField.heightAnchor.constraint(equalToConstant: adjustedSize.height).isActive = true
        commentTextField.layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        do {
            textView.isScrollEnabled = false
            textView.textContainer.heightTracksTextView = true
            try textView.validateTextViewCharacterCount()
        } catch CharacterCountLimitError.characterCountExceedsLimit {
            let alertController = UIAlertController(title: "Error", message: "Character count exceeds 1,000 character limit.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } catch {
            
        }
    }
    
    func fetchThreadComments() {
        guard let thread = thread else {return}
        let firebaseRequests = FirebaseRequests()
        firebaseRequests.observeChildAdded(reference: reference.child(thread.category).child(thread.key).child("comments"), completion: {(comment: Comment?, error) in
            if error != nil {
                //handle error
            }
            if let comment = comment {
                if !(thread.comments?.contains(comment) ?? false) {
                    self.thread?.comments?.append(comment)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    @objc func keyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {return}
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -keyboardSize.height
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func textViewEndEditing(_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
    }
    
    func setTextFieldPlaceholderText() {
        commentTextField.text = "New comment..."
        commentTextField.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextField.textColor == UIColor.lightGray {
            commentTextField.textColor = UIColor.black
            commentTextField.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextField.text == "" || commentTextField.text == nil {
            setTextFieldPlaceholderText()
        }
    }
    
    @IBAction func postCommentButtonPressed(_ sender: Any) {
        guard let thread = thread, thread.locked == false else {return}
        let threadReference = reference.child(thread.category).child(thread.key)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: Date())
        if let postText = commentTextField.text, let user = Auth.auth().currentUser {
            let commentRef = reference.child(thread.category).child(thread.key).child("comments").childByAutoId()
            commentRef.updateChildValues(["Post": postText, "Owner": user.displayName!, "OwnerUid": user.uid, "Date": date, "Key": commentRef.key!])
            threadReference.updateChildValues(["LastActivity": date])
        }
        setTextFieldPlaceholderText()
        commentTextField.resignFirstResponder()
    }
    
    @IBAction func lockThreadButtonTapped(_ sender: Any) {
        guard let thread = thread else {return}
        let threadReference = reference.child(thread.category).child(thread.key)
        if threadLockedButton.image == UIImage(systemName: "lock.open.fill") {
            threadLockedButton.image = UIImage(systemName: "lock.fill")
            threadReference.updateChildValues(["Locked": true])
        } else if threadLockedButton.image == UIImage(systemName: "lock.fill") {
            threadLockedButton.image = UIImage(systemName: "lock.open.fill")
            threadReference.updateChildValues(["Locked": false])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return 1
        case 1:
            return thread?.comments?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainPost", for: indexPath) as! MainPostTableViewCell
            cell.titleLabel.text = thread?.title
            cell.ownerLabel.text = "By: \(thread!.owner)"
            cell.dateLabel.text = thread?.date
            cell.translatesAutoresizingMaskIntoConstraints = false
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
            let comment = thread?.comments?[indexPath.row]
            cell.postLabel.text = comment?.post
            cell.ownerLabel.text = "By: \(comment!.owner)"
            cell.dateLabel.text = comment?.date
            return cell
        }
        
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
