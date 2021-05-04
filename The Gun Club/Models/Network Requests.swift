//
//  Network Requests.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/12/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import Foundation
import Firebase

struct Network {
    
    func restApiCall<T: Codable>(_ request: URLRequest, completion: @escaping (T?, Error?) -> Void) {
        let jsonDecoder = JSONDecoder()
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            if error != nil {
                completion(nil, NetworkError.restError)
            }
            if let data = data {
                if let decodedData = try? jsonDecoder.decode(T.self, from: data) {
                    completion(decodedData, nil)
                }
            } else {
                completion(nil, NetworkError.jsonDataNotDecoded)
            }
        }).resume()
    }

    
    func queryModerators(completion: @escaping ([String]?, Error?) -> Void) {
        let reference = Database.database().reference().child("Moderators")
        reference.observeSingleEvent(of: .value, with: {(snapshot) in
            var moderators = [String]()
            if let strings = snapshot.value as? [Any] {
                strings.forEach({
                    if let string = $0 as? String {
                        moderators.append(string)
                    }
                })
                completion(moderators, nil)
            } else {
                completion(nil, NetworkError.restError)
            }
        })
    }
    
    func queryUserName(reference: DatabaseReference, completion: @escaping (User?, Error?) -> Void) {
        let jsonDecoder = JSONDecoder()
        reference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
                    if let user = try? jsonDecoder.decode(User.self, from: data) {
                        completion(user, nil)
                    } else {
                        completion(nil, NetworkError.jsonDataNotDecoded)
                    }
                }
            }
        })
    }
    
    func observeChildAdded <T: Codable> (reference: DatabaseReference, completion: @escaping (T?, Error?) -> Void) {
        let jsonDecoder = JSONDecoder()
        reference.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                    if let returnValue = try? jsonDecoder.decode(T.self, from: data) {
                        completion(returnValue, nil)
                    } else {
                        completion(nil, NetworkError.childAddedError)
                    }
                } catch {
                    completion(nil, NetworkError.dataNotSerialized)
                }
            }
        })
    }
    
    func observeSingleEvent <T: Codable> (reference: DatabaseReference, completion: @escaping ([T]?, Error?) -> Void) {
        let jsonDecoder = JSONDecoder()
        reference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                var returnArray = [T]()
                do {
                    try dictionary.forEach({(key, value) in
                        let data = try JSONSerialization.data(withJSONObject: value, options: [])
                        if let returnValue = try? jsonDecoder.decode(T.self, from: data) {
                            returnArray.append(returnValue)
                        }
                    })
                    completion(returnArray, nil)
                } catch {
                    completion(nil, NetworkError.dataNotSerialized)
                }
            }
        })
    }
    
    func observeThreadLockedStatus(reference: DatabaseReference, completion: @escaping (Bool?, Error?) -> Void) {
        reference.observe(.value, with: {(snapshot) in
            if let bool = snapshot.value as? Bool {
                completion(bool, nil)
            } else {
                completion(nil, NetworkError.restError)
            }
        })
    }
    
    func signOutUser(completion: @escaping (NetworkError?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(NetworkError.logoutError)
        }
    }
    
}
