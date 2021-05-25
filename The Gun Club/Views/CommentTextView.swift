
//
//  CommentTextView.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/3/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class CommentTextView: UITextView {
    
    var heightConstraint: NSLayoutConstraint!
    
    
    private func setUpView() {
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 40)
        heightConstraint.isActive = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 15
        self.isScrollEnabled = false
        self.textContainer.heightTracksTextView = true
    }
    
    func setPlaceholderText() {
        self.text = "New comment..."
        self.textColor = UIColor.lightGray
    }
    
    func setEmptyText() {
        if self.textColor == UIColor.lightGray {
            self.textColor = UIColor.black
            self.text = nil
        }
    }
    
    func lock() {
        self.isEditable = false
        self.text = "This thread is locked."
    }
    
    func lockForGuest() {
        self.isEditable = false
        self.text = "You must be signed in to comment."
        self.textColor = UIColor.lightGray
    }
    
    func unlock() {
        self.isEditable = true
        self.text = "New comment..."
    }
    
    func isFieldEmpty() -> Bool {
        return (self.text == "" || self.text == "New comment...")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
}
