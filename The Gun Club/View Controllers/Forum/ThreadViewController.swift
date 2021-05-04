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
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var threadLockedButton: UIBarButtonItem!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet var contentView: UIView!
    
    var thread: Thread?
    var moderators: [String]?
    var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    let reference = Database.database().reference().child("Threads")
    let firebaseRequests = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchModerators()
        fetchThreadComments()
        self.commentTextView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.commentTextViewHeightConstraint = commentTextView.heightAnchor.constraint(equalToConstant: 40)
        commentTextViewHeightConstraint.isActive = true
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
        commentTextView.layer.borderColor = UIColor.black.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 15
        commentTextView.isScrollEnabled = false
        commentTextView.textContainer.heightTracksTextView = true
        postCommentButton.layer.borderColor = UIColor(red255: 65, green: 105, blue: 225, alpha: 1).cgColor
        postCommentButton.layer.borderWidth = CGFloat(1)
        postCommentButton.layer.cornerRadius = 15
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
        firebaseRequests.queryModerators(completion: {[weak self] (moderators, error) in
            guard let self = self else {return}
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
        firebaseRequests.observeThreadLockedStatus(reference: reference.child(thread.category).child(thread.key).child("Locked"), completion: {[weak self](bool, error) in
            guard let self = self else {return}
            if let bool = bool {
                self.thread!.locked = bool
                self.threadLockedStatusDidChange()
            }
        })
    }
    
    func threadLockedStatusDidChange() {
        if thread!.locked == true {
            commentTextView.isEditable = false
            postCommentButton.isEnabled = false
            commentTextView.text = "This thread is locked."
        } else if thread!.locked == false {
            commentTextView.isEditable = true
            postCommentButton.isEnabled = true
            commentTextView.text = "New comment..."
        }
    }
    
    func adjustTextViewHeight() {
        let width = commentTextView.frame.width
        let adjustedSize = commentTextView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        if adjustedSize.height >= UIScreen.main.bounds.height / 3 {
            commentTextView.isScrollEnabled = true
        } else {
            commentTextView.isScrollEnabled = false
            commentTextView.textContainer.heightTracksTextView = true
            commentTextViewHeightConstraint.constant = adjustedSize.height
        }
        commentTextView.layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
        do {
            try textView.validateTextViewCharacterCount()
        } catch {
            let alertController = UIAlertController(title: "Error", message: "Character count exceeds 500 character limit.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchThreadComments() {
        guard let thread = thread else {return}
        let firebaseRequests = Network()
        firebaseRequests.observeChildAdded(reference: reference.child(thread.category).child(thread.key).child("comments"), completion: {[weak self] (comment: Comment?, error) in
            guard let self = self else {return}
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
    //Need to fix keyboard bugs
    @objc func keyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {return}
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.contentView.frame.origin.y -= keyboardSize.height
        } else {
            self.contentView.frame.origin.y = 0
        }
    }
    
    @objc func textViewEndEditing(_ sender: UITapGestureRecognizer) {
        if commentTextView.isFirstResponder {
            commentTextView.endEditing(true)
            commentTextView.resignFirstResponder()
        }
    }
    
    func setTextFieldPlaceholderText() {
        commentTextView.text = "New comment..."
        commentTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextView.textColor == UIColor.lightGray {
            commentTextView.textColor = UIColor.black
            commentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text == "" || commentTextView.text == nil {
            setTextFieldPlaceholderText()
        }
    }
    
    @IBAction func postCommentButtonPressed(_ sender: Any) {
        guard let thread = thread, thread.locked == false else {return}
        if commentTextView.text == "New comment..." || commentTextView.text == "" {
            return
        }
        let threadReference = reference.child(thread.category).child(thread.key)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: Date())
        if let postText = commentTextView.text, let user = Auth.auth().currentUser {
            let commentRef = reference.child(thread.category).child(thread.key).child("comments").childByAutoId()
            commentRef.updateChildValues(["Post": postText, "Owner": user.displayName!, "OwnerUid": user.uid, "Date": date, "Key": commentRef.key!])
            threadReference.updateChildValues(["LastActivity": date])
        }
        setTextFieldPlaceholderText()
        commentTextView.resignFirstResponder()
        adjustTextViewHeight()
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
            cell.postLabel.text = thread?.post
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
