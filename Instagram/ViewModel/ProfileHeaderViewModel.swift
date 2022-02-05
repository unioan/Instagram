//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by Владимир Юшков on 12.01.2022.
//

import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        if user.isCurrentUser {
            return .white
        }
        
        return user.isFollowed ? .systemGreen : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
        
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStackText(value: user.stats.followers, label: "followers")
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedStackText(value: user.stats.following, label: "following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStackText(value: user.stats.posts, label: "posts")
    }
    
    init(user: User) {
        self.user = user
    }
    
    func attributedStackText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font : UIFont.systemFont(ofSize: 12),
                                                                             .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
}
