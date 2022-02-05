//
//  ImageUploader.swift
//  Instagram
//
//  Created by Владимир Юшков on 11.01.2022.
//

import FirebaseStorage
import UIKit

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) { // После отправки картинки в FStore мы получим ссылку на скачивание этой картинки.
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload imge \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, error in
                guard let imgeURL = url?.absoluteString else { return }
                completion(imgeURL)
            }
        }
    }
}
