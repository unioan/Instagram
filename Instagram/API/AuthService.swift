//
//  AuthService.swift
//  Instagram
//
//  Created by Владимир Юшков on 11.01.2022.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static func logUserIn(with email: String, password: String, compleation: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: compleation)
    }
    
    static func registerUser(withCredential credential: AuthCredentials, compleation: @escaping(Error?) -> Void) {
        ImageUploader.uploadImage(image: credential.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credential.email, password: credential.password) { result, error in
                if let error = error {
                    print("DEBUG: Failed to register user \(error.localizedDescription)")
                    return // Выйдет полностью из функции
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["email": credential.email,
                                           "fullname": credential.fullname,
                                           "profileImageUrl": imageUrl,
                                           "uid": uid,
                                           "username": credential.username]
                
                COLLECTION_USERS.document(uid).setData(data, completion: compleation) 
            }
        }
    }
    
    static func resetPassword(withEmail email: String, completion: (SendPasswordResetCallback)?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}
