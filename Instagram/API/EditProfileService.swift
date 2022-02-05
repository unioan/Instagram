//
//  EditProfileService.swift
//  Instagram
//
//  Created by Владимир Юшков on 30.01.2022.
//

import Foundation
import Firebase

struct EditProfileService {
    
    static func updateUserProfileImage(currentUser: User, editedProfile: EditProfileModel, compleation: @escaping (String?) -> ()) {
        let currentUserUid = currentUser.uid
        
            if let profileImage = editedProfile.profileImage {
                ImageUploader.uploadImage(image: profileImage) { profileImageURL in
                    updateProfileImageInUserProfile(for: currentUserUid, with: profileImageURL)
                    updateProfileImageInPosts(for: currentUserUid, with: profileImageURL)
                    updateProfileImageInNotifications(for: currentUserUid, with: profileImageURL)
                    updateProfileImageInComments(for: currentUserUid, with: profileImageURL)
                    compleation(profileImageURL)
                    print("DEBUG 1 profile Photo has been updated")
                }
            }
            
            if let fullname = editedProfile.fullname {
                COLLECTION_USERS.document(currentUserUid).updateData(["fullname": fullname])
                if editedProfile.profileImage == nil { compleation(nil) }
                print("DEBUG 2 profile Fullname has been updated")
            }
            
            if let username = editedProfile.username {
                updateUsernameInProfile(for: currentUserUid, with: username)
                updateUsernameInPosts(for: currentUserUid, with: username)
                updateUsernameInNotifications(for: currentUserUid, with: username)
                updateUsernameInComments(for: currentUserUid, with: username)
                if editedProfile.profileImage == nil { compleation(nil) }
                print("DEBUG 3 profile Username has been updated")
            }
        
    }
    
    
    
    private static func updateProfileImageInUserProfile(for userUid: String, with imageUrl: String) {
        COLLECTION_USERS.document(userUid).updateData(["profileImageUrl": imageUrl])
    }
    
    private static func updateProfileImageInPosts(for userUid: String, with imageUrl: String) {
        let postQuery = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: userUid)
        postQuery.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { COLLECTION_POSTS.document($0.documentID).updateData(["ownerImageUrl" : imageUrl])  }
        }
    }
    
    private static func updateProfileImageInNotifications(for userUid: String, with imageUrl: String) {
        COLLECTION_NOTIFICATIONS.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            documents.forEach { document in
                
                if document.documentID != userUid {
                    let notificationQuery = COLLECTION_NOTIFICATIONS.document(document.documentID).collection("user-notifications").whereField("uid", isEqualTo: userUid)
                    notificationQuery.getDocuments { snapshot, error in
                        guard let documents = snapshot?.documents else { return }
                        documents.forEach {
                            COLLECTION_NOTIFICATIONS.document(document.documentID).collection("user-notifications").document($0.documentID).updateData(["userProfileImageUrl": imageUrl])
                        }
                    }
                }
            }
        }
    }
    
    private static func updateProfileImageInComments(for userUid: String, with imageUrl: String) {
        COLLECTION_POSTS.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { post in 
                let commentsQuery = COLLECTION_POSTS.document(post.documentID).collection("comments").whereField("uid", isEqualTo: userUid)
                commentsQuery.getDocuments { snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    documents.forEach { comment in
                        COLLECTION_POSTS.document(post.documentID).collection("comments").document(comment.documentID).updateData(["profileImageUrl": imageUrl])
                    }
                }
            }
        }
    }
    
    
    
    
    
    private static func updateUsernameInProfile(for userUid: String, with username: String) {
        COLLECTION_USERS.document(userUid).updateData(["username": username])
    }
    
    private static func updateUsernameInPosts(for userUid: String, with username: String) {
        let postQuery = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: userUid)
        postQuery.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { COLLECTION_POSTS.document($0.documentID).updateData(["ownerUserName" : username])  }
        }
    }
    
    private static func updateUsernameInNotifications(for userUid: String, with username: String) {
        COLLECTION_NOTIFICATIONS.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            documents.forEach { document in
                
                if document.documentID != userUid {
                    let notificationQuery = COLLECTION_NOTIFICATIONS.document(document.documentID).collection("user-notifications").whereField("uid", isEqualTo: userUid)
                    notificationQuery.getDocuments { snapshot, error in
                        guard let documents = snapshot?.documents else { return }
                        documents.forEach {
                            COLLECTION_NOTIFICATIONS.document(document.documentID).collection("user-notifications").document($0.documentID).updateData(["username": username])
                        }
                    }
                }
            }
        }
    }
    
    private static func updateUsernameInComments(for userUid: String, with username: String) {
        COLLECTION_POSTS.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { post in
                let commentsQuery = COLLECTION_POSTS.document(post.documentID).collection("comments").whereField("uid", isEqualTo: userUid)
                commentsQuery.getDocuments { snapshot, _ in
                    guard let documents = snapshot?.documents else { return }
                    documents.forEach { comment in
                        COLLECTION_POSTS.document(post.documentID).collection("comments").document(comment.documentID).updateData(["username": username])
                    }
                }
            }
        }
    }
    
    
    
    
    
}
