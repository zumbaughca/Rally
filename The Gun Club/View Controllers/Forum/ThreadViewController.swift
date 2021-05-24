//
//  ThreadViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase
// TODO: Add blocked post/user filtering methods
class ThreadViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CommentTableViewCellDelegate, MainPostTableViewCellDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var threadLockedButton: UIBarButtonItem!
    @IBOutlet weak var postCommentButton: PostCommentButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var thread: ForumThread?
    var moderators: [String]?
    let reference = Database.database().reference().child("Threads")
    let commentReference = Database.database().reference().child("Comments")
    let networkRequests = Network()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchModerators()
        fetchUser(Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid)) {
            [unowned self] user in
            if let user = user {
                self.user = user
                self.fetchThreadComments()
            }
        }
        //fetchThreadComments()
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
    
    func fetchUser(_ reference: DatabaseReference, completion: @escaping (_ user: User?) -> Void) {
        networkRequests.queryUserName(reference: reference, completion: {(user, error) in
            if let user = user {
                completion(user)
            } else {
                completion(nil)
            }
        })
    }
    
    func fetchThreadComments() {
        guard let thread = thread else {return}
        let firebaseRequests = Network()
        firebaseRequests.observeChildAdded(reference: commentReference.child(thread.key), completion: {[weak self] (comment: Comment?, error) in
            guard let self = self else {return}
            if let error = error {
                self.createErrorAlert(for: error.localizedDescription)
            }
            if let comment = comment {
                print(self.user!.blockedUsers)
                if !(thread.comments?.contains(comment) ?? false) && self.user!.shouldSeeContent(post: comment) {
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
            //let commentRef = reference.child(thread.category).child(thread.key).child("comments").childByAutoId()
            let commentRef = commentReference.child(thread.key).childByAutoId()
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

// MARK: CommentTableViewCellDelegate methods
extension ThreadViewController {
    
    private func reportUser(of post: Comment) {
        Database.database().reference().child("ReportedUsers").child(post.ownerUid).updateChildValues([post.owner: post.post])
    }
    
    private func blockUser(of post: Comment) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("BlockedUsers").updateChildValues([post.ownerUid: true])
    }
    
    private func blockPost(of post: Comment) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("BlockedPosts").updateChildValues([post.key: true])
    }
    
    private func createReportAlert(for post: Comment) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report User", style: .default, handler: {[unowned self] (action) in
            self.createAlertToConfirmReport(message: "You are reporting this user for the content of this post. This information will be reviewed by the moderators within 24 hours. If deemed necessary, disciplinary actions will be taken against this user. You will not be notified of any actions taken. To proceed with this report press Yes.", handler: {
                [unowned self] in
                self.reportUser(of: post)
            })
        })
        let blockUserAction = UIAlertAction(title: "Block User", style: .default, handler: {[unowned self] action in
            self.createAlertToConfirmReport(message: "You are blocking the user of this post. You will no longer see any content from this user. Press Yes to proceed.", handler: {
                [unowned self] in
                self.blockUser(of: post)
            })
        })
        let blockPostAction = UIAlertAction(title: "Block Post", style: .default, handler: {[unowned self] action in
            self.createAlertToConfirmReport(message: "You are blocking this post. You will no longer see this post, but you will still see other posts from this user. Press Yes to proceed.", handler: {
                [unowned self] in
                self.blockPost(of: post)
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(blockUserAction)
        alert.addAction(blockPostAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapReportButton(_ sender: CommentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender), let post =  indexPath.section == 1 ? thread!.comments![indexPath.row] : thread else { return }
        createReportAlert(for: post)
    }
    
    func didTapMainPostReportButton(_ sender: MainPostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender), let post =  indexPath.section == 1 ? thread!.comments![indexPath.row] : thread else { return }
        print(post.owner)
        createReportAlert(for: post)
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
            cell.delegate = self
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.selectionStyle = .none
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
            let comment = thread?.comments?[indexPath.row]
            cell.postLabel.text = comment?.post
            cell.ownerLabel.text = "By: \(comment!.owner)"
            cell.dateLabel.text = comment?.date
            cell.delegate = self
            cell.selectionStyle = .none
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
        networkRequests.queryModerators(completion: {[weak self] (moderators, error) in
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
        networkRequests.observeThreadLockedStatus(reference: reference.child(thread.category).child(thread.key).child("Locked"), completion: {[weak self](bool, error) in
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
