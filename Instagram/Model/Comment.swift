//
//  Comment.swift
//  Instagram
//
//  Created by Владимир Юшков on 16.01.2022.
//

import Firebase

struct Comment {
    let uid: String
    let username: String
    let profileImageUrl: String
    let timestamp: Timestamp
    var commentText: String
    
    init(dictionary: [String: Any]) {
        
        uid = dictionary["uid"] as? String ?? ""
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        commentText = dictionary["comment"] as? String ?? ""
        timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
