//
//  UploadPostController.swift
//  Instagram
//
//  Created by Владимир Юшков on 13.01.2022.
//

import UIKit

protocol UploadPostControllerDelegate: AnyObject {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController)
}

class UploadPostController: UIViewController {
    
    // MARK: Properties
    var selectedImage: UIImage? { 
        didSet { photoImageView.image = selectedImage }
    }
    
    weak var delegate: UploadPostControllerDelegate?
    
    var currentUser: User?
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var captionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Enter caption..."
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.delegate = self
        tv.placeholderShouldCenter = false
        return tv
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()

    
    // MARK: Life Cycle
    override func viewDidLoad() {
      configureUI()
        print("DEBUG UploadPostController")
    }
    
    
    // MARK: Actions
    @objc func didTappedCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDone() {
        guard let caption = captionTextView.text else { return }
        guard let image = selectedImage else { return }
        guard let user = currentUser else { return }

        
        showLoader(true)
        
        PostService.uploadPost(caption: caption, image: image, user: user) { error in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: Failed to upload post with error \(error.localizedDescription)")
                return
            }
            
            self.delegate?.controllerDidFinishUploadingPost(self)
        }
    }
    
    
    // MARK: Helpers
    func checkMaxLenght(_ textView: UITextView) {
        if textView.text.count > 100 {
            textView.deleteBackward()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Upload Post"
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTappedCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done,
                                                            target: self, action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingRight:  12, height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(bottom: captionTextView.bottomAnchor, right: view.rightAnchor, paddingBottom: -8, paddingRight: 12)
    }
        
}

    // MARK: - UITextViewDelegate
extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLenght(textView)
        let count = textView.text.count
        characterCountLabel.text = "\(count)/100"
    }
}
