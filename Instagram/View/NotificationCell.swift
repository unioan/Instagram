//
//  NotificationCell.swift
//  Instagram
//
//  Created by Владимир Юшков on 18.01.2022.
//

import UIKit
import PryntTrimmerView

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String)
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String)
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String)
}


class NotificationCell: UITableViewCell {
    static let identifier = "NotificationCell"
    
    // MARK: Properties
    var viewModel: NotificationViewModel? {
        didSet {
            configure()
            configureUI()
        }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "Rome")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: Actions
    @objc func handleFollowTapped() {
        guard let viewModel = viewModel else { return }

        if viewModel.notification.isFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.uid)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.uid)
        }
    }
    
    @objc func handlePostTapped() {
        guard let postId = viewModel?.notification.postId else { return }
        delegate?.cell(self, wantsToViewPost: postId)
    }
    
    
    // MARK: Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        configureUI()
    }
    
    
    // MARK: Helpers
    func configureUI() {
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(postImageView)
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 12, width: 40, height: 40)
        
        addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 88, height: 32)
        
        addSubview(infoLabel)
        infoLabel.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        if viewModel?.notification.type == .follow {
            postImageView.removeFromSuperview() // До вызова этого метода кнопка получала констрейнты postImageView (40, 40) становясь квадратной
            infoLabel.anchor(right: followButton.leftAnchor, paddingRight: 4)
        } else {
            followButton.removeFromSuperview()
            infoLabel.anchor(right: postImageView.leftAnchor, paddingRight: 4)
        }
    }
    
    
    func configure() {
        guard let viewModel = viewModel else { return }

        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        postImageView.sd_setImage(with: viewModel.postImageUrl)
        infoLabel.attributedText = viewModel.notificationMessage
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        postImageView.isHidden = viewModel.shouldHidePostImage
        
        followButton.setTitle(viewModel.followButtonText, for: .normal)
        followButton.backgroundColor = viewModel.followButtonColor
        followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
