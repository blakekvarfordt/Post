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
    
    func fetchPosts(completion: @escaping() -> Void) {
        guard let url = baseURL else { return }
        let getterEndPoint = url.appendingPathExtension("json")
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
                self.posts = posts
            } catch {
                print( "\(error)\(error.localizedDescription)")
            }; completion(); return
            
        } .resume()
        
        
    }
}
