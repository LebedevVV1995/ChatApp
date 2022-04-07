//
//  TabBarController.swift
//  ChatApp
//
//  Created by Владимир on 14.10.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit

class TabBarController: UIViewController {
    let tabBarCnt = UITabBarController()    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarCnt.tabBar.tintColor = UIColor.black
        createTabBarController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createTabBarController() {
        let firstVC = ConversationsViewController()
        firstVC.title = "Chats"
        firstVC.tabBarItem = UITabBarItem.init(title: "Chats", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 0)
        
        let secondVC = ProfileViewController()
        secondVC.title = "Profile"
        secondVC.tabBarItem = UITabBarItem.init(title: "Profile", image: UIImage.init(systemName: "gear"), tag: 1)
        
        let contrArray = [firstVC, secondVC]
        tabBarCnt.viewControllers = contrArray.map{ UINavigationController.init(rootViewController: $0)}
        self.view.addSubview(tabBarCnt.view)
    }
}
