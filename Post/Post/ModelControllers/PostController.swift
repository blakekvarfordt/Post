//
//  PostController.swift
//  Post
//
//  Created by Blake kvarfordt on 8/12/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation

class PostController {
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts = [Post]()
    
    // GET function that allows us to fetch the data
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        guard let url = baseURL else { return }
        
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
        
        let queryItems = urlParameters.compactMap ({ URLQueryItem(name: $0.key, value: $0.value)})
        
        var urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let thisURL = urlComponents?.url else { completion(); return }
        
        
        let getterEndPoint = thisURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: getterEndPoint)
        urlRequest.httpBody = nil
        urlRequest.httpMethod = "GET"
        
        let _ = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
            if let error = error {
                print("Error fetching data \(error)")
                completion(); return
            }
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let postDictionary = try decoder.decode([String : Post].self, from: data)
                var posts = postDictionary.compactMap({$0.value})
                posts.sort(by: ({ $0.timestamp > $1.timestamp}))
                
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(contentsOf: posts)
                }
                
                
                completion()
            } catch {
                print( "\(error)\(error.localizedDescription)")
                completion()
                return
            }

            } .resume()
    }
    
   // POST function which will allow us to post to the API
    func addNewPost(username: String, text: String, completion: @escaping (Bool) -> Void) {
        let post = Post(username: username, text: text)
        var postData: Data?
        guard let url = baseURL else { return }
        let postEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        request.httpBody = postData
        request.httpMethod = "POST"
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(post)
            postData = data
        } catch {
            print("Error trying to add Post \(error) \(error.localizedDescription)")
            completion(false); return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print("Error with the request \(error) \(error.localizedDescription)")
                completion(false); return
            }
            guard let data = data else { return }
            if let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            self.fetchPosts() {
                completion(true)
            }
            
            
        } .resume()
    }
}
