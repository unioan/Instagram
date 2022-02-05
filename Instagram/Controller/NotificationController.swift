//
//  NotificationController.swift
//  Instagram
//
//  Created by Владимир Юшков on 09.01.2022.
//

import UIKit


class NotificationController: UITableViewController {
    
    // MARK: Properties
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    private let refresher = UIRefreshControl()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        fetchNotifications()
    }
    

    // MARK: API
    func fetchNotifications() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
            self.checkIfUserIsFollowed()
        }
    }
    
    func checkIfUserIsFollowed() {
        notifications.forEach { notification in
            guard notification.type == .follow else { return }
            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in 
                guard let index = self.notifications.firstIndex(where: { $0.postId == notification.postId }) else { return }
                self.notifications[index].isFollowed = isFollowed
            }
        }
    }
    
    
    // MARK: Actions
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
    
    // MARK: Helpers
    func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
}

// MARK: - UITableViewDataSource
extension NotificationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        
        UserService.fetchUser(withUid: notifications[indexPath.row].uid) { user in
            self.showLoader(false)
            
            guard let postId = self.notifications[indexPath.row].postId else { return }
            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            PostService.fetchPost(with: postId) { post in
                controller.post = post
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: - NotificationCellDelegate
extension NotificationController: NotificationCellDelegate {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        showLoader(true)
        
        UserService.follow(uid: uid) { _ in
            self.showLoader(false)
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.notifications[indexPath.row].isFollowed.toggle()
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        showLoader(true)
        
        UserService.unfollow(uid: uid) { _ in
            self.showLoader(false)
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.notifications[indexPath.row].isFollowed.toggle()
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        showLoader(true)
        
        PostService.fetchPost(with: postId) { post in
            self.showLoader(false)
            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
}
