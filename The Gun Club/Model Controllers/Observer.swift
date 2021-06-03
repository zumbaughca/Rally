//
//  Observer.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 6/2/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import Foundation

protocol Observer: AnyObject {
    func dataDidUpdate()
}

protocol Observable {
    func notifyObserver()
}
