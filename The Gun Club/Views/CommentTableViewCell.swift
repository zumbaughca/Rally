//
//  CommentCollectionViewCell.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class CommentTableViewCell: UITableViewCell {
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
     }()
     
     let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
     }()
    
    private func configureLayout() {
        postLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        postLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        postLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        ownerLabel.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: 4).isActive = true
        ownerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        ownerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: ownerLabel.trailingAnchor, constant: 8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: ownerLabel.bottomAnchor).isActive = true
        
     }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(postLabel)
        self.contentView.addSubview(ownerLabel)
        self.contentView.addSubview(dateLabel)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
