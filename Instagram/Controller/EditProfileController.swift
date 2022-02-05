//
//  EditProfileController.swift
//  Instagram
//
//  Created by Владимир Юшков on 26.01.2022.
//

import UIKit

protocol EditProfileControllerDelegate: AnyObject {
    func didSaveChangesInProfile(_ editProfileController: EditProfileController, editedProfile: EditProfileModel?)
}

class EditProfileController: UICollectionViewController {
    
    //MARK: Properties
    var user: User
    var editedProfile: EditProfileModel
    weak var delegate: EditProfileControllerDelegate?
    
    //MARK: Life Cycle
    init(user: User) {
        self.user = user
        editedProfile = EditProfileModel(user: user)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func viewDidLoad() {
        registerKeyboardNotifications()
        configureUI()
    }
    
    deinit {
        removeKeyboardNotificationsObserver()
    }
    
    //MARK: Actions
    @objc func handleSaveButtonPressed() {
        showLoader(true)
        EditProfileService.updateUserProfileImage(currentUser: user, editedProfile: editedProfile) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delegate?.didSaveChangesInProfile(self, editedProfile: self.editedProfile)
                self.showLoader(false)
                print("DEBUG: compleation has been triggered, profileImageUrl")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleBackButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleShowKeyboard(_ notification: NSNotification) {
        guard let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let addOffsetWhenKeyboardAppeared = UIEdgeInsets(top: kbSize.height - view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = addOffsetWhenKeyboardAppeared
    }
    
    @objc func handleHideKeyboard() {
        let removeOffsetAfterKeyboardDisapired = UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = removeOffsetAfterKeyboardDisapired
    }
    
    //MARK: Helpers
    func configureUI() {
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(EditProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: EditProfileHeader.identifier)
        collectionView.register(EditProfileCell.self,
                                forCellWithReuseIdentifier: EditProfileCell.identifier)
        
        navigationItem.title = "Edit Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(handleSaveButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(handleBackButtonPressed))
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotificationsObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource
extension EditProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditProfileCell.identifier, for: indexPath) as! EditProfileCell
        cell.delegat = self
        cell.editCellViewModel = editedProfile
        
        if editedProfile.username != nil {
            cell.editCellViewModel?.username = editedProfile.username
        } else {
            cell.editCellViewModel?.username = user.username
        }
        
        if editedProfile.fullname != nil {
            cell.editCellViewModel?.fullname = editedProfile.fullname
        } else {
            cell.editCellViewModel?.fullname = user.fullname
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EditProfileHeader.identifier, for: indexPath) as! EditProfileHeader
        
        header.delegat = self
        
        if editedProfile.profileImage != nil {
            header.profileImageView.image = editedProfile.profileImage
        } else {
            header.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl))
        }
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EditProfileController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Cell Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 240 - view.safeAreaInsets.top)
    }
    
    // MARK: Header Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}



// MARK: - EditProfileCellDelegat
extension EditProfileController: EditProfileCellDelegat {
    func setTextFieldDelegates(for fullnameTF: UITextField, and usernameTF: UITextField) {
        fullnameTF.delegate = self
        usernameTF.delegate = self
    }
    
    func handleTextFieldsChanges(fullnameTF: String?, usernameTF: String?) {
        guard let fullnameTF = fullnameTF,
              let usernameTF = usernameTF else { return }
        
        if fullnameTF.contains(user.fullname) {
            editedProfile.fullname = nil
        } else {
            editedProfile.fullname = fullnameTF
        }
        
        if usernameTF.contains(user.username) {
            editedProfile.username = nil
        } else {
            editedProfile.username = usernameTF
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension EditProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



// MARK: - UIImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return } 
        
        editedProfile.profileImage = selectedImage
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileHeaderDelegat
extension EditProfileController: EditProfileHeaderDelegat {
    func handleImagePicking() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
}
