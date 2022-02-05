//
//  CustomNavigationController.swift
//  Instagram
//
//  Created by Владимир Юшков on 10.01.2022.
//


// Проблема с statusBar https://www.youtube.com/watch?v=6AJ__9E928o


import UIKit

class NavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
