//
//  ProfileController.swift
//  Instagram
//
//  Created by Владимир Юшков on 09.01.2022.
//

import UIKit


class ProfileController: UICollectionViewController {
    
    // MARK: Properties
    private var user: User
    private var posts = [Post]()
    
    // MARK: Life Cycle
    init(user: User) { 
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchPosts()
    }
    
    // MARK: API
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: self.user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: self.user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
            
        }
    }
    
    func fetchPosts() {
        PostService.fetchPosts(forUser: user.uid) { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Helpers
    func configureCollectionView() {
        navigationItem.title = user.username
        
        collectionView.backgroundColor = .white
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ProfileHeader.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - UICollectionViewDataSource
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
        cell.postViewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        header.delegate = self
        
        header.viewModel = ProfileHeaderViewModel(user: self.user)
        
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        PostService.fetchPost(with: posts[indexPath.row].postId) { post in
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    // MARK: Cells Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3 // Отнимаем 2 т.к. minimumInteritemSpacingForSectionAt заставляет одну ячейку отступить от другой на 1. Так как эту команду выполняет каждая отдельная ячейка то совокупное расстояние между ячейками становится 2. Такая же логика для ряов, тот что сверху отступает от нижнего на 1, а тот что снизу отступает от верхнего на 1.
        return CGSize(width: width, height: width)
    }
    
    // MARK: Header Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        guard let mainTabVC = tabBarController as? MainTabController,
              let currentUser = mainTabVC.user else { return }
        
        
        if user.isCurrentUser {
            let controller = UINavigationController(rootViewController: EditProfileController(user: self.user))
            let profileController = controller.topViewController as! EditProfileController
            profileController.delegate = self
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
            
        } else if user.isFollowed {
            UserService.unfollow(uid: user.uid) { error in
                self.user.isFollowed = false
                self.collectionView.reloadData()
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)
            }
        } else {
            UserService.follow(uid: user.uid) { error in 
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.uploadNotification(toUid: user.uid, currentUser: currentUser, type: .follow)
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
            }
        }
    }
    
}


extension ProfileController: EditProfileControllerDelegate {
    func didSaveChangesInProfile(_ editProfileController: EditProfileController, editedProfile: EditProfileModel?) {
        guard editedProfile != nil else { return }
        
        print("DEBUG delegate triggered")
        guard let mainTabVC = tabBarController as? MainTabController,
              let navController = mainTabVC.viewControllers?.first as? UINavigationController,
              let feedController = navController.viewControllers.first as? FeedController else { return }
        
        feedController.handleRefresh()

        UserService.fetchUser(withUid: user.uid) { user in
            self.user = user
            self.configureCollectionView()
            self.fetchUserStats()
            self.collectionView.reloadData()
        }
        
    }
    
}

