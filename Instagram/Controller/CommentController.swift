//
//  CommentController.swift
//  Instagram
//
//  Created by Владимир Юшков on 15.01.2022.
//

import UIKit

class CommentController: UICollectionViewController {
    
    // MARK: Properties
    
    private let post: Post
    private var comments = [Comment]()
    
    // Мы будем добавлять на данный контроллер кастомный CommentInputAccessoryView в качестве его AccessoryView
    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cv = CommentInputAccessoryView(frame: frame)
        cv.delegate = self // Так как это lazy property мы можем обратиться к self еще до инициализации класса CommentController и вызова функции viewDidLoad
        return cv
    }()
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: Life Cycle
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configureCollectionView()
        fetchComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: API
    func fetchComments() {
        CommentService.fetchComments(forPost: post.postId) { comments in // Вызывается каждый раз после того как кто-то оставил коммент так как в базе установлен listner
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Helpers
    func configureCollectionView() {
        navigationItem.title = "Comments"
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        
        collectionView.alwaysBounceVertical = true // Если не включить, то не будет работать scroll при небольшом кол-во ячеек
        collectionView.keyboardDismissMode = .interactive // При сколле экрана вниз скроет клавиатуру
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource
extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - CommentInputAccessoryViewDelegate
extension CommentController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        
        guard let tab = tabBarController as? MainTabController,
              let currentUser = tab.user else { return }
        
        showLoader(true)
        
        CommentService.uploadComment(comment: comment, postID: post.postId, user: currentUser) { error in
            self.showLoader(false)
            inputView.clearCommentTextView()
            
            NotificationService.uploadNotification(toUid: self.post.ownerUid, currentUser: currentUser, type: .comment, post: self.post)
        }
    }
    
}

// MARK: - UICollectionDelegate
extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { // По нажатию на comment cell отправит нас на страницу оставившего коммент
        let uid = comments[indexPath.row].uid
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
