//
//  SceneDelegate.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 7/23/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let stateController = StateController(networkModule: Network())

    private func instantiateViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        stateController.attachListner()
        return viewController
        //self.window?.rootViewController = viewController
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.window = self.window ?? UIWindow()
        
        if Auth.auth().currentUser == nil {
            let vc = instantiateViewController(identifier: "LoginController") as! LoginViewController
            vc.stateController = stateController
            self.window?.rootViewController = vc
        } else {
            Auth.auth().currentUser?.reload(completion: {[weak self] (error) in
                if error == nil {
                    let vc = self?.instantiateViewController(identifier: "TabBarController") as! TabBarViewController
                    vc.stateController = self?.stateController
                    self?.window?.rootViewController = vc
                } else {
                    let vc = self?.instantiateViewController(identifier: "LoginController") as! LoginViewController
                    vc.stateController = self?.stateController
                    self?.window?.rootViewController = vc
                }
            })
        }
            
        
        guard let _ = (scene as? UIWindowScene) else { return }
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

