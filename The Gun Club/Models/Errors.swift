//
//  Errors.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/26/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation

enum CharacterCountLimitError: Error, LocalizedError {
    case characterCountExceedsLimit
    
    var errorDescription: String? {
        switch self {
        case .characterCountExceedsLimit:
            return "Character count exceeds 500 character limit."
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case childAddedError
    case dataNotSerialized
    case noDataReturned
    case logoutError
    case rallyObserverError
    case restError
    case jsonDataNotDecoded
    
    var errorDescription: String? {
        switch self {
        case .noDataReturned:
            return "No data was returned from the server."
        case .logoutError:
            return "There was an error logging you out. Check your internet connection and try again"
        default:
            return "An error occured. Please try again later."
        }
    }
}

