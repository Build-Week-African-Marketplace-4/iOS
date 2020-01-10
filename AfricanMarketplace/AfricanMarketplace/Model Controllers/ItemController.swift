//
//  UserController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation
import CoreData

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

class ItemController {
    
    static let sharedInstance = ItemController()
    
    private let baseURL = URL(string: "https://africanmarket2.herokuapp.com/")!
    
    var users: [User] = []
    var token: Token?
    var items: [CDItem] = []
    var searchedItems: [CDItemRepresentation] = []
    
    init() {
        fetchItems { (result) in
            DispatchQueue.main.async {
                
            }
        }
    }
    
    
    func searchForItem(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        let requestURL = baseURL.appendingPathComponent("api/item/search/:\(searchTerm)")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for item with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from search task")
                completion(NSError())
                return
            }
            
            do {
                let itemQueryResult = try JSONDecoder().decode(CDItemRepresentations.self, from: data).results
                self.searchedItems = itemQueryResult
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    
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
            
            if let response = response as? HTTPURLResponse, response.statusCode != 201 || response.statusCode != 200 {
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
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.token = try decoder.decode(Token.self, from: data)
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
    
    func fetchUsers(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        guard let token = token else {
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
                let userInfo = try decoder.decode([User].self, from: data)
                self.users = userInfo
                completion(.success(userInfo))
            } catch {
                print("Error decoding [UserInfo] object: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func fetchItem(completion: @escaping (Error?) -> Void = { _ in}) {

        let itemsURL = baseURL.appendingPathComponent("api/item")
        
        var request = URLRequest(url: itemsURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching items: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned in fetch")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let itemRepresentations = Array(try JSONDecoder().decode([String: CDItemRepresentation].self, from: data).values)
                try self.updateItems(with: itemRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding item representation: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func fetchItems(completion: @escaping (Result<[CDItemRepresentation], NetworkError>) -> Void) {

        let gigURL = baseURL.appendingPathComponent("api/item")

        var request = URLRequest(url: gigURL)
        request.httpMethod = HTTPMethod.get.rawValue

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }

            if let error = error {
                print("Error receiving gig data: \(error)")
                completion(.failure(.otherError))
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let items = try decoder.decode([CDItemRepresentation].self, from: data)
                self.searchedItems = items
                completion(.success(items))
                try self.updateItems(with: items)
            } catch {
                print("Error decoding [Item] object: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func sendItemToServer(item: CDItemRepresentation, completion: @escaping (Error?) -> ()) {
        guard let token = token else {
            print("Error Authenticating")
            completion(nil)
            return
        }
        
        let itemURL = baseURL.appendingPathComponent("api/item")
        
        var request = URLRequest(url: itemURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
        
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
    
    func add(item: CDItemRepresentation, completion: @escaping (Error?) -> ()) {
           guard let token = token else {
               print("No Auth")
               completion(nil)
               return
           }

           let gigURL = baseURL.appendingPathComponent("api/item")

           var request = URLRequest(url: gigURL)
           request.httpMethod = HTTPMethod.post.rawValue
           request.addValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")

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
    
    func deleteItemFromServer(_ item: CDItemRepresentation, completion: @escaping (Error?) -> Void = { _ in}) {
        
    }
    
    func updateItems(with representation: [CDItemRepresentation]) throws {
        let entriesWithId = representation.filter { $0.item_id != nil }
        let identifiersToFetch = entriesWithId.compactMap { $0.item_id! }
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithId))

        var entriesToCreate = representationByID

        let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            do {
                let existingItems = try context.fetch(fetchRequest)

                for item in existingItems {
                    guard let id = item.item_id,
                        let representation = representationByID[id] else { continue }

                    self.update(item: item, with: representation)
                    entriesToCreate.removeValue(forKey: id)
                }

                for representation in entriesToCreate.values {
                    CDItem(itemRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching entries for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }
    
    func put(item: CDItem, completion: @escaping (Error?) -> Void = { _ in }) {
        let uuid = item.item_id ?? UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard var representation = item.cdItemRepresentation else {
                completion(NSError())
                return
            }
            representation.item_id = uuid
            item.item_id = uuid
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion(error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error putting item to server \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func hasFavorited(for item: CDItem) {
        item.favorite.toggle()
        put(item: item)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error updating favorite status \(error)")
        }
    }
    
    private func update(item: CDItem, with representation: CDItemRepresentation) {
        item.name = representation.name
        item.price = representation.price
        item.city = representation.city
        item.country = representation.country
        item.itemDescription = representation.description
        item.favorite = representation.favorite ?? false
    }
    
    
    
}
