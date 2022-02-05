//
//  User.swift
//  Instagram
//
//  Created by Владимир Юшков on 12.01.2022.
//

import Foundation
import Firebase

struct User {
    let email: String
    let fullname: String
    let profileImageUrl: String
    let username: String
    let uid: String
    
    var isFollowed = false
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    var stats: UserStats!
    
    init(dictionary: [String: Any]) { 
        email = dictionary["email"] as? String ?? ""
        fullname = dictionary["fullname"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        username = dictionary["username"] as? String ?? ""
        uid = dictionary["uid"] as? String ?? ""
        
        stats = UserStats(followers: 0, following: 0, posts: 0)
    }
}

struct UserStats {
    let followers: Int
    let following: Int
    let posts: Int
}
