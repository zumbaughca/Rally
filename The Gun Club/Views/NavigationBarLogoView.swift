//
//  NavigationBarLogoView.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 5/9/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

class NavigationBarLogoView: UIView {
    
    let image: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        return imageView
    }()
    
    private func configureLayout() {
        self.addSubview(image)
        self.layer.cornerRadius = 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
