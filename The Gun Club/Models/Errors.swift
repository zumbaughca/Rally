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

enum TextFieldValidationError: Error, LocalizedError {
    case textFieldIsEmpty
    case postTitleIsEmpty
    case restrictedTitle
    
    var errorDescription: String? {
        switch self {
        case .textFieldIsEmpty:
            return "Your post must not be empty"
        case .postTitleIsEmpty:
            return "Your post must have a title"
        case .restrictedTitle:
            return "This title is restricted. Please use a different title."
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

enum RegistrationErrors: Error, LocalizedError {
    case passwordsDoNotMatch
    case noEmailProvided
    case noScreenNameProvided
    case noZipCodeProvided
    case noNameProvided
    case screenNameAlreadyExists
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            return "The passwords do not match"
        case .noEmailProvided:
            return "You must provide a valid email"
        case .noScreenNameProvided:
            return "You must provide a screen name."
        case .noZipCodeProvided:
            return "You must provide a zip code"
        case .noNameProvided:
            return "You must provide a name"
        case .screenNameAlreadyExists:
            return "This screen name already exists"
        case .unknownError:
            return "An error occured, please try again later."
        }
    }
}

