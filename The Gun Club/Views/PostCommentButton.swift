//
//  PostCommentButton.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/3/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class PostCommentButton: UIButton {
    
    private func setUpView() {
        self.layer.borderWidth = CGFloat(1)
        self.layer.cornerRadius = 15
        unlock()
    }
    
    func lock() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.isEnabled = false
    }
    
    func unlock() {
        self.layer.borderColor = UIColor(red255: 65, green: 105, blue: 225, alpha: 1).cgColor
        self.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
}
