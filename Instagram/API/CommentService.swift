//
//  CommentService.swift
//  Instagram
//
//  Created by Владимир Юшков on 16.01.2022.
//

import Firebase

struct CommentService {
    static func uploadComment(comment: String, postID: String, user: User, compleation: @escaping (FirestoreCompletion)) {
        let data: [String: Any] = ["uid": user.uid, // Это структура данных коммента
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "profileImageUrl": user.profileImageUrl]
 
        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data, completion: compleation)
    }
    
    static func fetchComments(forPost postID: String, compleation: @escaping ([Comment]) -> Void) {
        var comments = [Comment]()
        
        let query = COLLECTION_POSTS.document(postID).collection("comments").order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, error in
            
            snapshot?.documentChanges.forEach{ change in
                if change.type == .added {
                    
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                    comments.sort { $0.timestamp.seconds > $1.timestamp.seconds } 
                }
            }
            compleation(comments)
        }
    }
}

