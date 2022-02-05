//
//  Post.swift
//  Instagram
//
//  Created by Владимир Юшков on 14.01.2022.
//

import Firebase
import Foundation

struct Post {
    var caption: String
    var likes: Int
    let imageUrl: String
    let ownerUid: String
    let timeStamp: Timestamp
    let postId: String // Не добавлен внутрь докуумета (в коллекцию Firestore), это название документа в котором лежит коллекция, его генерирует Firestore автоматически при добавлении документа.
    let ownerImageUrl: String
    let ownerUserName: String
    var didLike = false
    
    init(postId: String, dictionary: [String: Any]) { 
        self.postId = postId
        
        caption = dictionary["caption"] as? String ?? ""
        likes = dictionary["likes"] as? Int ?? 0
        imageUrl = dictionary["imageUrl"] as? String ?? ""
        ownerUid = dictionary["ownerUid"] as? String ?? ""
        timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp(date: Date())
        
        ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        ownerUserName = dictionary["ownerUserName"] as? String ?? ""
    }
    
}
