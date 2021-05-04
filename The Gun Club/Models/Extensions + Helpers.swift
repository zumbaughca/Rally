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
    
    func adjustTextViewHeight(screenHeight: CGFloat, heightConstraint: NSLayoutConstraint) {
        let width = self.frame.width
        let adjustedSize = self.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        if adjustedSize.height >= screenHeight {
            self.isScrollEnabled = true
        } else {
            self.isScrollEnabled = false
            self.textContainer.heightTracksTextView = true
            heightConstraint.constant = adjustedSize.height
        }
        self.layoutIfNeeded()
    }
}

extension UIColor {
    convenience init(red255 red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

extension DateFormatter {
    func getFormattedStringFromCurrentDate() -> String {
        self.dateStyle = .medium
        self.timeStyle = .medium
        self.locale = Locale(identifier: "en_US")
        return self.string(from: Date())
    }
}

extension UIViewController {
    func createErrorAlert(for error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
