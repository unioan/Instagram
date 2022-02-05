//
//  UserService.swift
//  Instagram
//
//  Created by Владимир Юшков on 11.01.2022.
//

import Firebase
typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    static func fetchUser(withUid uid: String, completion: @escaping (User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping ([User]) -> Void) {
        COLLECTION_USERS.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            let users = snapshot.documents.map { User(dictionary: $0.data()) }
            completion(users)
        }
    }
    
    static func follow(uid: String, compleation: @escaping FirestoreCompletion) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUID).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUID).setData([:], completion: compleation)
        }
    }
    
    static func unfollow(uid: String, compleation: @escaping FirestoreCompletion) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUID).collection("user-following").document(uid).delete { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUID).delete(completion: compleation)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, compleation: @escaping (Bool) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUID).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else { return }
            compleation(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, compleation: @escaping (UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
                    let amountOfPosts = snapshot?.documents.count ?? 0
                    compleation(UserStats(followers: followers, following: following, posts: amountOfPosts))
                }
                
            }
        }
    }
    
}
