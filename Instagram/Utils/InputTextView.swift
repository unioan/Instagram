//
//  inputTextView.swift
//  Instagram
//
//  Created by Владимир Юшков on 13.01.2022.
//

import UIKit

class InputTextView: UITextView {
    
    // MARK: Properties
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText}
    }
    
    let placeholderLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    var placeholderShouldCenter = true {
        didSet {
            if placeholderShouldCenter {
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
                placeholderLabel.centerY(inView: self)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
            }
        }
    }
    
    
    // MARK: Life Cycle
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    
    // MARK: Actions
    @objc func handleTextDidChange() {
        placeholderLabel.isHidden = !text.isEmpty 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
