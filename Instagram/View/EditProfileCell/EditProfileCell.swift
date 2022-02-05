//
//  EditProfileCell.swift
//  Instagram
//
//  Created by Владимир Юшков on 27.01.2022.
//

import UIKit

protocol EditProfileCellDelegat: AnyObject {
    func handleTextFieldsChanges(fullnameTF: String?, usernameTF: String?)
    func setTextFieldDelegates(for fullnameTF: UITextField, and usernameTF: UITextField)
}

class EditProfileCell: UICollectionViewCell {
    
    static let identifier = "EditProfileCell"
    
    var editCellViewModel: EditProfileModel? {
        didSet { configure() }
    }
    
    weak var delegat: EditProfileCellDelegat?
    
    
    //MARK: Properties
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Name"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Username"
        return label
    }()
    
    private let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full name goes here..."
        tf.addTarget(self, action: #selector(textFieldInputChanged), for: .editingChanged)
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username goes here..."
        tf.addTarget(self, action: #selector(textFieldInputChanged), for: .editingChanged)
        return tf
    }()
    
    
    //MARK: Actions
    @objc func textFieldInputChanged() {
        let fullnameTF = fullNameTextField.text
        let usernameTF = usernameTextField.text?.lowercased()
        
        usernameTextField.text = usernameTF // Не позволяет писать заглавными буквами
  
        delegat?.handleTextFieldsChanges(fullnameTF: fullnameTF, usernameTF: usernameTF)
        delegat?.setTextFieldDelegates(for: fullNameTextField, and: usernameTextField)
    }
    
    
    //MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(nameLabel)
        nameLabel.setDimensions(height: 40, width: 100)
        nameLabel.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8)
        
        addSubview(usernameLabel)
        usernameLabel.setDimensions(height: 40, width: 100)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        contentView.addSubview(fullNameTextField)
        fullNameTextField.setHeight(40)
        fullNameTextField.anchor(top: topAnchor, left: nameLabel.rightAnchor, right: rightAnchor,
                                                 paddingLeft: 8, paddingRight: 8)
        
        contentView.addSubview(usernameTextField)
        usernameTextField.setHeight(40)
        usernameTextField.anchor(top: fullNameTextField.bottomAnchor, left: usernameLabel.rightAnchor, right: rightAnchor,
                                 paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        
        let fulnameDivider = UIView()
        fulnameDivider.backgroundColor = .lightGray
        addSubview(fulnameDivider)
        fulnameDivider.anchor(top: fullNameTextField.bottomAnchor, left: fullNameTextField.leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.5)
        
        let usernameDivider = UIView()
        usernameDivider.backgroundColor = .lightGray
        addSubview(usernameDivider)
        usernameDivider.anchor(top: usernameTextField.bottomAnchor, left: usernameTextField.leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.5)
        
    }
    
    
    //MARK: Helpers
    func configure() {
        guard let viewModel = editCellViewModel else { return }
        fullNameTextField.text = viewModel.fullname
        usernameTextField.text = viewModel.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

