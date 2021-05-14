//
//  BillTableViewCell.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 3/13/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class BillTableViewCell: UITableViewCell {
    
    let labelFrame: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let billTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let introducedLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lastActionDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func configureLayout() {
        labelFrame.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        labelFrame.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        labelFrame.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        labelFrame.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        billTitle.topAnchor.constraint(equalTo: labelFrame.topAnchor, constant: 8).isActive = true
        billTitle.leadingAnchor.constraint(equalTo: labelFrame.leadingAnchor, constant: 10).isActive = true
        billTitle.trailingAnchor.constraint(equalTo: labelFrame.trailingAnchor, constant: -10).isActive = true
        
        introducedLabel.topAnchor.constraint(equalTo: lastActionDateLabel.bottomAnchor, constant: 5).isActive = true
        introducedLabel.leadingAnchor.constraint(equalTo: labelFrame.leadingAnchor, constant: 10).isActive = true
        introducedLabel.bottomAnchor.constraint(equalTo: labelFrame.bottomAnchor, constant: -10).isActive = true
        
        lastActionDateLabel.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 10).isActive = true
        lastActionDateLabel.leadingAnchor.constraint(equalTo: labelFrame.leadingAnchor, constant: 10).isActive = true
        lastActionDateLabel.trailingAnchor.constraint(equalTo: labelFrame.trailingAnchor, constant: -10).isActive = true
                
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.labelFrame.backgroundColor = UIColor(red255: 178, green: 72, blue: 68, alpha: 0.5)
        } else {
            self.labelFrame.backgroundColor = .white
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.labelFrame.addSubview(billTitle)
        self.labelFrame.addSubview(introducedLabel)
        self.labelFrame.addSubview(lastActionDateLabel)
        self.contentView.addSubview(labelFrame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
