//
//  MainSplitViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit


class MainSplitViewController : UISplitViewController, UISplitViewControllerDelegate {
    var leftViewController: LeftSideViewController
    var rightViewController: RightSideViewController
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.leftViewController = LeftSideViewController()
        self.rightViewController = RightSideViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.viewControllers = [ self.leftViewController,
                                 self.rightViewController ]
        
        self.primaryBackgroundStyle = .sidebar
        
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        self.leftViewController = LeftSideViewController()
        self.rightViewController = RightSideViewController()
        super.init(coder: coder)
    }
    
//    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
//        guard splitViewController.isCollapsed == true //,
////            let tabBarController = splitViewController.viewControllers.first as? UITabBarController,
////            let navigationController = tabBarController.selectedViewController as? UINavigationController
//        else {
//            return false
//        }
//
//        var viewControllerToPush = vc
//        if let otherNavigationController = vc as? UINavigationController {
//            if let topViewController = otherNavigationController.topViewController {
//                viewControllerToPush = topViewController
//            }
//        }
//        viewControllerToPush.hidesBottomBarWhenPushed = true
//        navigationController.pushViewController(viewControllerToPush, animated: true)
//
//        return true
//    }
}
