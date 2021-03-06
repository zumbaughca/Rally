//
//  ThreadViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class ThreadViewController: UIViewController, UITextViewDelegate, CommentTableViewCellDelegate, MainPostTableViewCellDelegate, Observer {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var threadLockedButton: UIBarButtonItem!
    @IBOutlet weak var postCommentButton: PostCommentButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var thread: ForumThread
    var moderators: [String]?
    let reference = Database.database().reference().child("Threads")
    let commentReference = Database.database().reference().child("Comments")
    var user: User?
    let threadModelController: ThreadModelController
    var stateController: StateController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threadModelController.observer = self
        stateController.observer = self
        user = stateController.getCurrentUser()
        commentTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.titleView = NavigationBarLogoView()
        tableView.register(MainPostTableViewCell.self, forCellReuseIdentifier: "mainPost")
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "comment")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewEndEditing))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stateController.observer = self
        if let user = user {
            threadModelController.fetchThreadComments(for: user, of: thread, at: commentReference)
        } else {
            threadModelController.fetchThreadComments(for: nil, of: self.thread, at: commentReference)
        }
    }
    
    init?(coder: NSCoder, threadModelController: ThreadModelController, thread: ForumThread, stateController: StateController) {
        self.threadModelController = threadModelController
        self.thread = thread
        self.stateController = stateController
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func dataDidUpdate() {
        tableView.reloadData()
    }
    
    func updateUI() {
        guard let user = Auth.auth().currentUser else {
            configureLockedStatusForGuest()
            return
        }
        tableView.separatorStyle = .none
        if user.uid != thread.ownerUid && !stateController.isUserModerator() {
            threadLockedButton.isEnabled = false
        }
        threadLockedStatusDidChange()
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
        guard thread.locked == false else {return}
        do {
            commentTextView.removePlaceholderText(text: "New comment...")
            try commentTextView.validateIsNotEmpty()
            threadModelController.postComment(commentTextView.text, thread: thread)
            commentTextView.setPlaceholderText()
            commentTextView.resignFirstResponder()
            adjustTextViewHeight()
        } catch {
            self.createErrorAlert(for: error.localizedDescription)
        }
    }
    
    @IBAction func lockThreadButtonTapped(_ sender: Any) {
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
    
    private func createReportAlert(for post: Comment, at indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report User", style: .default, handler: {[unowned self] (action) in
            self.createAlertToConfirmReport(message: "You are reporting this user for the content of this post. This information will be reviewed by the moderators within 24 hours. If deemed necessary, disciplinary actions will be taken against this user. You will not be notified of any actions taken. To proceed with this report press Yes.", handler: {
                [unowned self] in
                self.stateController.reportUser(of: post)
                self.createGenericAlert(title: nil, message: "Your report has been sent to the moderators for review.")
            })
        })
        let blockUserAction = UIAlertAction(title: "Block User", style: .default, handler: {[unowned self] action in
            self.createAlertToConfirmReport(message: "You are blocking the user of this post. You will no longer see any content from this user. Press Yes to proceed.", handler: {
                [unowned self] in
                self.stateController.blockUser(of: post)
                guard indexPath.section == 1 else { return }
                thread.comments?.remove(at: indexPath.row)
                tableView.reloadData()
            })
        })
        let blockPostAction = UIAlertAction(title: "Block Post", style: .default, handler: {[unowned self] action in
            self.createAlertToConfirmReport(message: "You are blocking this post. You will no longer see this post, but you will still see other posts from this user. Press Yes to proceed.", handler: {
                [unowned self] in
                self.stateController.blockPost(of: post)
                guard indexPath.section == 1 else { return }
                thread.comments?.remove(at: indexPath.row)
                tableView.reloadData()
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(blockUserAction)
        alert.addAction(blockPostAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.tabBarController?.tabBar
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapReportButton(_ sender: CommentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let post =  indexPath.section == 1 ? thread.comments![indexPath.row] : thread
        createReportAlert(for: post, at: indexPath)
    }
    
    func didTapMainPostReportButton(_ sender: MainPostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let post =  indexPath.section == 1 ? thread.comments![indexPath.row] : thread
        print(post.owner)
        createReportAlert(for: post, at: indexPath)
    }
    
}

// MARK: Table View Delegate and Data Source methods
extension ThreadViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return 1
        case 1:
            return thread.comments?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = Auth.auth().currentUser
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainPost", for: indexPath) as! MainPostTableViewCell
            cell.reportButton.isEnabled = user != nil ? true : false
            cell.titleLabel.text = thread.title
            cell.postLabel.text = thread.post
            cell.ownerLabel.text = "By: \(thread.owner)"
            cell.dateLabel.text = thread.date
            cell.delegate = self
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.selectionStyle = .none
            if thread.title == "README" {
                cell.reportButton.isEnabled = false
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentTableViewCell
            cell.reportButton.isEnabled = user != nil ? true : false
            let comment = thread.comments?[indexPath.row]
            cell.postLabel.text =  comment?.post
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
    
    func configureLockedStatusForGuest() {
        threadLockedButton.image = UIImage(systemName: "lock.fill")
        threadLockedButton.isEnabled = false
        commentTextView.lockForGuest()
        postCommentButton.lock()
    }
    
    func threadLockedStatusDidChange() {
        if thread.locked == true {
            threadLockedButton.image = UIImage(systemName: "lock.fill")
            commentTextView.lock()
            postCommentButton.lock()
        } else if thread.locked == false {
            threadLockedButton.image = UIImage(systemName: "lock.open.fill")
            commentTextView.unlock()
            postCommentButton.unlock()
            commentTextView.setPlaceholderText()
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
