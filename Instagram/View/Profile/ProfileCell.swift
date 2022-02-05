//
//  ProfileCell.swift
//  Instagram
//
//  Created by Владимир Юшков on 11.01.2022.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    static let identifier = "ProfileCell"
    
    // MARK: Properties
    var postViewModel: PostViewModel? {
        didSet { configure() }
    }
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "Rome")
        return iv
    }()
    
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    func configure() {
        self.postImageView.sd_setImage(with: postViewModel?.imageUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
