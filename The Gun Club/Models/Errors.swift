//
//  Errors.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/26/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

enum CharacterCountLimitError: Error {
    case characterCountExceedsLimit
}

enum NetworkError: Error {
    case childAddedError
    case dataNotSerialized
    case noDataReturned
    case logoutError
    case rallyObserverError
    case restError
    case jsonDataNotDecoded
}

enum RallyError: Error {
    case nameIsEmpty
    case dateNotSet
    case locationNotSet
    case descriptionIsEmpty
}
