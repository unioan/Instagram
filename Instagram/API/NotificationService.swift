//
//  NotificationService.swift
//  Instagram
//
//  Created by Владимир Юшков on 19.01.2022.
//

import Firebase

struct NotificationService {
    static func uploadNotification(toUid uid: String,
                                   currentUser: User,
                                   type: NotificationType,
                                   post: Post? = nil) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": currentUser.uid,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "userProfileImageUrl": currentUser.profileImageUrl,
                                   "username": currentUser.username]
        
        if let post = post {
            data["postId"] = post.postId
            data["postImageUrl"] = post.imageUrl
            
        }
        COLLECTION_NOTIFICATIONS.document(uid).setData(["placeholder": "to get collection"])
        docRef.setData(data)
        
    }
    
    
    static func fetchNotifications(compleation: @escaping ([Notification]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications").order(by: "timestamp", descending: true)
        
        query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            let notifications = documents.map { Notification(dictionary: $0.data())}
            compleation(notifications)
        }
        
    }
    
}
