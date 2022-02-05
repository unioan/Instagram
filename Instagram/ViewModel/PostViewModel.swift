//
//  PostViewModel.swift
//  Instagram
//
//  Created by Владимир Юшков on 14.01.2022.
//

import UIKit

struct PostViewModel {
    
    var post: Post
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var username: String {
        return post.ownerUserName
    }
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int { 
        return post.likes
    }
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    var timestampString: String? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "en")
        
        let formater = DateComponentsFormatter()
        formater.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formater.maximumUnitCount = 1
        formater.unitsStyle = .full
        formater.calendar = calendar
        return formater.string(from: post.timeStamp.dateValue(), to: Date())
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "like_selected" : "like_unselected"
        return UIImage(named: imageName)
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .red : .black
    }
    
    init(post: Post) {
        self.post = post
    }
    
    
    
    
}
