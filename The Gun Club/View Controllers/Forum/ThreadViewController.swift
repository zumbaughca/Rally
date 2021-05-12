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
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var threadLockedButton: UIBarButtonItem!
    @IBOutlet weak var postCommentButton: PostCommentButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var thread: ForumThread?
    var moderators: [String]?
    let reference = Database.database().reference().child("Threads")
    let firebaseRequests = Network()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchModerators()
        fetchThreadComments()
        self.commentTextView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.titleView = NavigationBarLogoView()
        tableView.register(MainPostTableViewCell.self, forCellReuseIdentifier: "mainPost")
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "comment")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewEndEditing))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        updateUI()
        fetchLockedStatus()
        commentTextView.setPlaceholderText()
    }
    
    func updateUI() {
        guard let user = Auth.auth().currentUser, let thread = thread else {return}
        tableView.separatorStyle = .none
        
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
    
    
    

    
    func fetchThreadComments() {
        guard let thread = thread else {return}
        let firebaseRequests = Network()
        firebaseRequests.observeChildAdded(reference: reference.child(thread.category).child(thread.key).child("comments"), completion: {[weak self] (comment: Comment?, error) in
            guard let self = self else {return}
            if let error = error {
                self.createErrorAlert(for: error.localizedDescription)
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
    
    /*
     * First ensure the thread is not locked and that the text field is not empty.
     * If we are good to proceed, grab the current date as a formatted string.
     * Create a new reference for this comment with childByAutoId()
     * Update the comments node to include the new comment
     * Update the threads last activity
     * Reset the UI
     */
    @IBAction func postCommentButtonPressed(_ sender: Any) {
        guard let thread = thread, thread.locked == false else {return}
        do {
            commentTextView.removePlaceholderText(text: "New comment...")
            try commentTextView.validateIsNotEmpty()
            postComment(commentTextView.text, thread: thread)
            commentTextView.setPlaceholderText()
            commentTextView.resignFirstResponder()
            adjustTextViewHeight()
        } catch {
            self.createErrorAlert(for: error.localizedDescription)
        }
    }
    
    func postComment(_ text: String, thread: ForumThread?) {
        guard let thread = thread else { return }
        let threadReference = reference.child(thread.category).child(thread.key)
        let date = DateFormatter().getFormattedStringFromCurrentDate()
        if let user = Auth.auth().currentUser {
            let commentRef = reference.child(thread.category).child(thread.key).child("comments").childByAutoId()
            commentRef.updateChildValues(["Post": text, "Owner": user.displayName!, "OwnerUid": user.uid, "Date": date, "Key": commentRef.key!])
            threadReference.updateChildValues(["LastActivity": date])
        }
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
}

// MARK: Table View
extension ThreadViewController {
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
}

// MARK: Moderation and thread locked status
extension ThreadViewController {
    // Only allow moderator privilages on thread if user is on mod list.
    func allowModeratorPrivileges() {
        guard let user = Auth.auth().currentUser, let moderators = moderators else {return}
        if moderators.contains(user.uid) {
            threadLockedButton.isEnabled = true
        }
    }
    
    // Get a list of the moderators when the thread is loaded.
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
            commentTextView.lock()
            postCommentButton.lock()
        } else if thread!.locked == false {
            commentTextView.unlock()
            postCommentButton.unlock()
        }
    }
}

//MARK: Comment text view associated methods
extension ThreadViewController {
    
    /*
     * The default height constraint on the comment text field is 40
     * We want to adjust the height to increase as new lines are added
     * until the text field occupies 1/3 of the screen
     */
    func adjustTextViewHeight() {
        commentTextView.adjustTextViewHeight(screenHeight: UIScreen.main.bounds.height / 3, heightConstraint: commentTextView.heightConstraint)
    }
    
    /*
     * Continue to adjust height as new lines are added
     * At each change, determine if the character count exceeds the limit
     * If it does, alert the user to reduce the count.
     */
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
        do {
            try textView.validateTextViewCharacterCount()
        } catch {
            self.createErrorAlert(for: error.localizedDescription)
        }
    }
    
    /*
     * First get the size of the keyboard
     * If the notification is that the keyboard will show:
     *      - Get the height of the tab bar
     *      - Then adjust the bottom constraint of the view to account for the keyboard and      tab bar
     * If the notification is that the keyboard will hide:
     * Reset the constraint back to 0.
     */
    @objc func keyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {return}
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
            viewBottomConstraint.constant = 0 + keyboardSize.height - tabBarHeight
        } else {
            viewBottomConstraint.constant = 0
        }
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func textViewEndEditing(_ sender: UITapGestureRecognizer) {
        if commentTextView.isFirstResponder {
            commentTextView.endEditing(true)
            commentTextView.resignFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        commentTextView.setEmptyText()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.isFieldEmpty() {
            commentTextView.setPlaceholderText()
        }
    }
}
