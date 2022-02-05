//
//  PostService.swift
//  Instagram
//
//  Created by Владимир Юшков on 13.01.2022.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(caption: String, image: UIImage, user: User, compleation: @escaping FirestoreCompletion) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timeStamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": currentUserUid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUserName": user.username] as [String: Any]
            
            let docRef = COLLECTION_POSTS.addDocument(data: data, completion: compleation)
            self.updeteUserFeedAfterPost(postId: docRef.documentID)
        }
    }
    
    static func fetchPosts(compleation: @escaping ([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timeStamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.map { Post(postId: $0.documentID, dictionary: $0.data())}
            compleation(posts)
        }
    }
    
    static func fetchPost(with postId: String, compleation: @escaping (Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, error in
            guard let snapshot = snapshot,
                  let data = snapshot.data() else { return }
            compleation(Post(postId: snapshot.documentID, dictionary: data))
        }
    }
    
    static func fetchPosts(forUser uid: String, compleation: @escaping ([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.map { Post(postId: $0.documentID, dictionary: $0.data())}
            let postsSorted = posts.sorted { $0.timeStamp.seconds > $1.timeStamp.seconds }
            compleation(postsSorted)
        }
    }
    
    static func likePost(post: Post, compleation: @escaping (FirestoreCompletion)) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        // Обновляет указанное поле новыми данными
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])

        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(currentUserUid).setData([:]) { _ in
            COLLECTION_USERS.document(currentUserUid).collection("user-likes").document(post.postId).setData([:], completion: compleation)
        }
    }
    
    static func unlikePost(post: Post, compleation: @escaping (FirestoreCompletion)) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(currentUserUid).delete { _ in
            COLLECTION_USERS.document(currentUserUid).collection("user-likes").document(post.postId).delete(completion: compleation)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping (Bool) -> Void) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUserUid).collection("user-likes").document(post.postId).getDocument { snapshot, error in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchFeedPosts(compleation: @escaping ([Post]) -> Void) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUserUid).collection("user-feed").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            var posts = [Post]()
            
            documents.forEach { document in
                fetchPost(with: document.documentID) { post in
                    posts.append(post)
                    compleation(posts.sorted { $0.timeStamp.seconds > $1.timeStamp.seconds })
                }
            }
        }
        
    }
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map { $0.documentID }
            
            docIDs.forEach { docID in
                if didFollow {
                COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(docID).setData([:])
                } else {
                    COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(docID).delete()
                }
            }
        }
    }
    
    static func updeteUserFeedAfterPost(postId: String) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWERS.document(currentUserUid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postId).setData([:])
            } 
            COLLECTION_USERS.document(currentUserUid).collection("user-feed").document(postId).setData([:])
        }
    }
    
}

