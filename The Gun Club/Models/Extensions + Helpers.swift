//
//  Extensions + Helpers.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/12/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (Double(Int(self)) * divisor) / divisor
    }
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map({ URLQueryItem(name: $0.key, value: $0.value)})
        return components?.url
    }
}

extension UITextView {
    func validateTextViewCharacterCount() throws {
        if self.text.count > 500 {
            self.text.removeLast()
            throw CharacterCountLimitError.characterCountExceedsLimit
        }
    }
}

extension CLLocationDistance {
    func toMiles() -> Double {
        return self / 1609.34
    }
}

extension UIColor {
    convenience init(red255 red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
