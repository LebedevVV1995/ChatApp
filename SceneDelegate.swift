//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Владимир on 20.07.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        //let vC = UserInfoController()
        
        if Auth.auth().currentUser == nil{
            let VC = NewUsersPhoneViewController(nibName: nil, bundle: nil)
            let navVC = UINavigationController(rootViewController: VC)
            window?.rootViewController = navVC
        }else{
            let VC = TabBarController(nibName: nil, bundle: nil)
            window?.rootViewController = VC
        }
//        }else if Auth.auth().currentUser != nil && vC.switcher == false{
//            let vc = UserInfoController(nibName: nil, bundle: nil)
//            let navVC = UINavigationController(rootViewController: vc)
//            window?.rootViewController = navVC
//        }else if Auth.auth().currentUser != nil && vC.switcher == true {
//            let vc = ChatsViewController(nibName: nil, bundle: nil)
//            let navVC = UINavigationController(rootViewController: vc)
//            window?.rootViewController = navVC
//        }
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

