//
//  Post.swift
//  Post
//
//  Created by Blake kvarfordt on 8/12/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import Foundation

struct Post: Codable {
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    
    var queryTimestamp: TimeInterval {
       return self.timestamp - 0.00001
    }
    
    
    
    
}
