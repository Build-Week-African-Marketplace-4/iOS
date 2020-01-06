//
//  UserController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case badAuth
    case noAuth
    case otherError
    case badData
    case noDecode
}

class UserController {
    
    private let baseURL = URL(string: "https://africanmarket2.herokuapp.com/")!
    
    var userInfo: [UserInfo] = []
    var authToken: AuthToken?
    var items: [Item] = []
    
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        
        let signUpUrl = baseURL.appendingPathComponent("api/auth/register")
        
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            DispatchQueue.main.async {
            completion(nil)
            }
        }.resume()
    }
    
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        
        let signInUrl = baseURL.appendingPathComponent("api/auth/login")
        
        var request = URLRequest(url: signInUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 201 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.authToken = try decoder.decode(AuthToken.self, from: data)
            } catch {
                print("Error decoding user info \(error)")
                completion(error)
                return
            }
            
            DispatchQueue.main.async {
            completion(nil)
            }
        }.resume()
    }
    
    func fetchUserInfo(completion: @escaping (Result<[UserInfo], NetworkError>) -> Void) {
        guard let token = authToken else {
            completion(.failure(.noAuth))
            return
        }

        let userInfoURL = baseURL.appendingPathComponent("api/users/:id")

        var request = URLRequest(url: userInfoURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }

            if let error = error {
                print("Error receiving User Info data: \(error)")
                completion(.failure(.otherError))
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let userInfo = try decoder.decode([UserInfo].self, from: data)
                self.userInfo = userInfo
                completion(.success(userInfo))
            } catch {
                print("Error decoding [UserInfo] object: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    
    func fetchItems(completion: @escaping (Result<[Item], NetworkError>) -> Void) {

        let itemsURL = baseURL.appendingPathComponent("api/item")

        var request = URLRequest(url: itemsURL)
        request.httpMethod = HTTPMethod.get.rawValue

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }

            if let error = error {
                print("Error receiving item data: \(error)")
                completion(.failure(.otherError))
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let items = try decoder.decode([Item].self, from: data)
                self.items = items
                completion(.success(items))
            } catch {
                print("Error decoding [UserInfo] object: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func sendItemToServer(item: Item, completion: @escaping (Error?) -> ()) {
        guard let authToken = authToken else {
            print("Error Authenticating")
            completion(nil)
            return
        }
        
        let itemURL = baseURL.appendingPathComponent("api/item")
        
        var request = URLRequest(url: itemURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Bearer \(authToken.token)", forHTTPHeaderField: "Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let newItem = try encoder.encode(item)
            request.httpBody = newItem
        } catch {
            print("Error encoding item object: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                print("Bad Auth")
                completion(nil)
                return
            }

            if let error = error {
                print("Error receiving item data: \(error)")
                completion(nil)
                return
            } else {
                self.fetchItems { result in
                }
            }
        }.resume()
        
    }
}
