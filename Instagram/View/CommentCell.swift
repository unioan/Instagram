//
//  CommentCell.swift
//  Instagram
//
//  Created by Владимир Юшков on 15.01.2022.
//

import UIKit

class CommentCell: UICollectionViewCell {
    static let identifier = "CommentCell"
    
    var viewModel: CommentViewModel? {
        didSet{ configure() }
    }
    
    // MARK: Properties
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = UIImage(named: "Rome")
        return iv
    }()
    
    private let commentLabel = UILabel()
    
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(commentLabel)
        commentLabel.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        commentLabel.anchor(right: rightAnchor, paddingRight: 8)
        
        commentLabel.numberOfLines = 0
    }
    
    
    // MARK: Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        commentLabel.attributedText = viewModel.commentLabelText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
