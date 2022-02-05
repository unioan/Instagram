//
//  NotificationViewModel.swift
//  Instagram
//
//  Created by Владимир Юшков on 19.01.2022.
//

import UIKit

struct NotificationViewModel {
    
    let notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var postImageUrl: URL? {
        guard let postImageUrl = notification.postImageUrl else { return nil }
        return URL(string: postImageUrl)
    }
    
    var profileImageUrl: URL? {
        return URL(string: notification.userProfileImageUrl)
    }
    
    var timestampString: String? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "en")
        
        let formater = DateComponentsFormatter()
        formater.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formater.maximumUnitCount = 1
        formater.unitsStyle = .abbreviated
        formater.calendar = calendar
        return formater.string(from: notification.timestamp.dateValue(), to: Date())
    }
    
    var notificationMessage: NSAttributedString {
        let username = notification.username
        let message = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(message)", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " \(timestampString ?? "2m")", attributes: [.font: UIFont.systemFont(ofSize: 12),
                                                                             .foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var shouldHidePostImage: Bool { return self.notification.type == .follow }
    
    var shouldHideFollowButton: Bool { return self.notification.type != .follow }
    
    var followButtonText: String {
        return notification.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonColor: UIColor {
        return notification.isFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return notification.isFollowed ? .black : .white
    }
    
}
