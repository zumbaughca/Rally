//
//  Extensions + Helpers.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/12/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (Double(Int(self)) * divisor) / divisor
    }
}

extension String {
    func getDateFromString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension Array where Element: Comparable {
    mutating func insertInReverseOrder(_ element: Element) {
        guard self.count != 0 else {
            self.append(element)
            return
        }
        
        for i in 0 ..< self.count {
            if element >= self[i] {
                self.insert(element, at: i)
                return
            }
        }
        self.append(element)
        return
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
    
    func removePlaceholderText(text: String) {
        if self.text == text {
            self.text = ""
        }
    }
    
    func validateIsNotEmpty() throws {
        let text = self.text?.replacingOccurrences(of: " ", with: "")
        if text == nil || text == "" {
            throw TextFieldValidationError.textFieldIsEmpty
        }
    }
}

extension UITextField {
    func validateIsNotEmpty(with error: Error) throws {
        let text = self.text?.replacingOccurrences(of: " ", with: "")
        if text == nil || text == "" {
            throw error
        }
    }
    
    
    func validatePostTitleIsValid() throws {
        if self.text == "README" {
            throw TextFieldValidationError.restrictedTitle
        }
        let text = self.text?.replacingOccurrences(of: " ", with: "")
        if text == nil || text == "" {
            throw TextFieldValidationError.textFieldIsEmpty
        }
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
    
    func createGenericAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func createAlertToConfirmReport(message: String, handler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let userAction = UIAlertAction(title: "Yes", style: .default, handler: {
            _ in
            handler()
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(userAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func stringForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
