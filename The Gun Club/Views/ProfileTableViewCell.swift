//
//  ProfileTableViewCell.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/4/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    func setUpView() {
        self.contentView.backgroundColor = UIColor(named: "pastelRed")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
