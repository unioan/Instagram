//
//  MainTabController.swift
//  Instagram
//
//  Created by Владимир Юшков on 09.01.2022.
//

import UIKit
import Firebase
import YPImagePicker


class MainTabController: UITabBarController {
    
    // MARK: Properties
    var user: User? {
        didSet {
            guard let user = user else { return }
            configureViewControllers(withUser: user)
        }
    }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    
    // MARK: API
    func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        UserService.fetchUser(withUid: currentUser.uid) { user in
            self.user = user
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = NavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: Helpers
    func configureViewControllers(withUser user: User) {
        view.backgroundColor = .white
        
        self.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        let feed = tamplateNavigationController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: FeedController(collectionViewLayout: layout))
        
        let search = tamplateNavigationController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController: SearchController())
        
        let imageSelector = tamplateNavigationController(unselectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!, rootViewController: ImageSelectorController())
        
        let notification = tamplateNavigationController(unselectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!, rootViewController: NotificationController())
        
        let profileController = ProfileController(user: user)
        let profile = tamplateNavigationController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: profileController)
        
        viewControllers = [feed, search, imageSelector, notification, profile]
        
        tabBar.tintColor = .black
    }
    
    func tamplateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    func didFinishPickingMedia(_ picker: YPImagePicker) { // Возвращает картинку выбранную в YPImagePicker
        picker.didFinishPicking { items, cancelled in
            picker.dismiss(animated: false) {
                guard let selectedImage = items.singlePhoto?.image else { return }
                let controller = UploadPostController()
                controller.delegate = self
                controller.selectedImage = selectedImage
                controller.currentUser = self.user
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
    
}

// MARK: - AuthenticationDelegate (LoginController)
extension MainTabController: AuthenticationDelegate {
    func authenticationDidComplete() {
        fetchUser()
        self.dismiss(animated: true, completion: nil) // Скрывает LoginController и RegistrationController
    }
}
// MARK: - UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.hidesStatusBar = true
            config.hidesBottomBar = false
            config.library.maxNumberOfItems = 1
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            picker.imagePickerDelegate = self
            present(picker, animated: true, completion: nil)
            
            didFinishPickingMedia(picker)
        }
        
        return true
    }
}

//MARK: - UploadPostControllerDelegate
extension MainTabController: UploadPostControllerDelegate {
    
    func controllerDidFinishUploadingPost(_ controller: UploadPostController) { // Когда пользователь нжимает на share в UploadPostController с рабатывает этот метод.
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else { return } 
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        feed.handleRefresh()
    }
}
//MARK: - UploadPostControllerDelegate
extension MainTabController: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool { // После закрытия YPImagePicker возвращает пользователя на экран feed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.selectedIndex = 0
        }
        return true
    }
    

}
