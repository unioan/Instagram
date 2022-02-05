//
//  FeedController.swift
//  Instagram
//
//  Created by Владимир Юшков on 09.01.2022.
//

import UIKit
import Firebase

class FeedController: UICollectionViewController {
    
    // MARK: Properties
    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    var post: Post? {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureUI()
        fetchPosts()
        
        if post != nil {
            checkIfUserLikedPosts()
        }
        
    }
    
    
    // MARK: Actions
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func handleLogOut() {
        
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            
            let nav = NavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("DEBUG: Failed to sign out")
        }
    }
    
    @objc func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: API
    func fetchPosts() {
        guard post == nil else { return }
        
        PostService.fetchFeedPosts { posts in
            self.posts = posts
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
            
            self.checkIfUserLikedPosts()
        }
    }
    
    func checkIfUserLikedPosts() {
        
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { didLike in
                self.post?.didLike = didLike
                self.collectionView.reloadData()
            }
        } else {
            posts.forEach { post in
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    
                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId } ) {
                        self.posts[index].didLike = didLike
                    }
                }
            }
        }
    }
    
    
    // MARK: Helper
    func configureUI() {
        collectionView.backgroundColor = .white
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.identifier)
        
        if post == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogOut))
            navigationItem.title = "Feed"
            
            let refresher = UIRefreshControl()
            refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            collectionView.refreshControl = refresher
            
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = nil
        }
    }
    
}

    // MARK: - UICollectionViewDataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
   
        cell.delegat = self
        
        if let post = post {
            cell.viewModel = PostViewModel(post: post)
            cell.singlePostLayout = true
        } else {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.frame.width
        var height = width + 8 + 40 + 8 // width для высоты картинки поста / 8 отступ от верхнего края ячейки до картинки профиля / 40 высота картинки профиля / 8 от картинки верхнего края поста
        height += 50 // для кнопок под постом
        height += 60 // для комментов, лайков, даты поста
        
        return CGSize(width: width, height: height)
    }
    
}
// MARK: - FeedCellDelegate
extension FeedController: FeedCellDelegate {
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        guard let mainTabVC = tabBarController as? MainTabController,
              let currentUser = mainTabVC.user else { return }
        
        
        guard self.post == nil else {
            guard let singlePostDidLike = self.post?.didLike else { return }
            
            if singlePostDidLike {
                PostService.unlikePost(post: post) { _ in
                    self.post!.likes -= 1
                    self.post!.didLike.toggle()
                }
            } else {
                PostService.likePost(post: post) { _ in
                    self.post!.likes += 1
                    self.post!.didLike.toggle()
                }
            }
           
            return
        }
        
        if post.didLike {
            PostService.unlikePost(post: post) { _ in
                if let postIndex = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.posts[postIndex].likes -= 1
                    self.posts[postIndex].didLike.toggle()
                }
            }
        } else {
            PostService.likePost(post: post) { _ in
                if let postIndex = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.posts[postIndex].likes += 1
                    self.posts[postIndex].didLike.toggle()

                    NotificationService.uploadNotification(toUid: post.ownerUid,
                                                           currentUser: currentUser,
                                                           type: .like, post: post)
                }
            }
        }
        
    }
    
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        print("DEBUG: Shows profile")
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
