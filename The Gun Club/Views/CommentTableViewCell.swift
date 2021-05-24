//
//  CommentCollectionViewCell.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

protocol CommentTableViewCellDelegate: class {
    func didTapReportButton(_ sender: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {
    
    weak var delegate: CommentTableViewCellDelegate?
    
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
    
    let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "flag"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func configureLayout() {
        postLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        postLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        postLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        ownerLabel.topAnchor.constraint(equalTo: postLabel.bottomAnchor, constant: 4).isActive = true
        ownerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true

        dateLabel.leadingAnchor.constraint(equalTo: ownerLabel.trailingAnchor, constant: 8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: ownerLabel.bottomAnchor).isActive = true
        
        reportButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        reportButton.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 5).isActive = true
        reportButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
     }
    
    @objc func reportButtonTapped(_ sender: CommentTableViewCell) {
        delegate?.didTapReportButton(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(postLabel)
        self.contentView.addSubview(ownerLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(reportButton)

        reportButton.addTarget(self, action: #selector(reportButtonTapped(_:)), for: .touchUpInside)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
