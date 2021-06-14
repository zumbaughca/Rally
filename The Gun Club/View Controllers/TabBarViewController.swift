//
//  TabBarViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 6/2/21.
//  Copyright © 2021 Chuck Zumbaugh. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, Observer {

    var stateController: StateController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        stateController?.observer = self
        //setupChildViews()
        // Do any additional setup after loading the view.
    }
    
    func setupChildViews() {
        guard let viewControllers = viewControllers else { return }
        
        for viewController in viewControllers {
            let childVC: UIViewController?
            if let navController = viewController as? UINavigationController {
                childVC = navController.viewControllers.first
            } else {
                childVC = viewController
            }
            
            switch childVC {
            case let childVC as UserProfileViewController:
                childVC.stateController = stateController
            case let childVC as CategorySelectorViewController:
                childVC.stateController = stateController
            case let childVC as BillTableViewController:
                print("VC loaded")
                childVC.billModelController = BillModelController(networkModule: Network(), observer: nil)
            default:
                break
            }
        }
    }
    
    func dataDidUpdate() {
        //print(stateController?.getCurrentUser()?.name)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
