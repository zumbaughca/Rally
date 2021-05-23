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
    func didTapBlockUserButton(_ sender: CommentTableViewCell)
    func didTapBlockPostButton(_ sender: CommentTableViewCell)
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
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("Report", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let blockPostButton: UIButton = {
        let button = UIButton()
        button.setTitle("Block Post", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let blockUserButton: UIButton = {
        let button = UIButton()
        button.setTitle("Block User", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
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
        
        buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 5).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
     }
    
    @objc func reportButtonTapped(_ sender: CommentTableViewCell) {
        delegate?.didTapReportButton(self)
    }
    
    @objc func blockPostButtonTapped(_ sender: CommentTableViewCell) {
        delegate?.didTapBlockPostButton(self)
    }
    
    @objc func blockUserButtonTapped(_ sender: CommentTableViewCell) {
        delegate?.didTapBlockUserButton(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(postLabel)
        self.contentView.addSubview(ownerLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(reportButton)
        buttonStackView.addArrangedSubview(blockUserButton)
        buttonStackView.addArrangedSubview(blockPostButton)
        reportButton.addTarget(self, action: #selector(reportButtonTapped(_:)), for: .touchUpInside)
        blockPostButton.addTarget(self, action: #selector(blockPostButtonTapped(_:)), for: .touchUpInside)
        blockUserButton.addTarget(self, action: #selector(blockUserButtonTapped(_:)), for: .touchUpInside)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
