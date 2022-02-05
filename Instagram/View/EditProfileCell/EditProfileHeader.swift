//
//  EditProfileHeader.swift
//  Instagram
//
//  Created by Владимир Юшков on 27.01.2022.
//

import UIKit

protocol EditProfileHeaderDelegat: AnyObject {
    func handleImagePicking()
}


class EditProfileHeader: UICollectionReusableView {
    
    static let identifier = "EditProfileHeader"
    
    weak var delegat: EditProfileHeaderDelegat?
    
    // MARK: Properties
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChangePhotoButtonTapped))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleChangePhotoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -30)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        
        addSubview(changePhotoButton)
        changePhotoButton.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        changePhotoButton.centerX(inView: self)
    }
    
    
    // MARK: Actions
    @objc func handleChangePhotoButtonTapped() {
        print("DEBUG: EditProfileHeader changePhotoButton tapped")
        delegat?.handleImagePicking()
    }
    
    
    
    
    // MARK: Helpers    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

