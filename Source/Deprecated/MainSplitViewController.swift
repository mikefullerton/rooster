//
//  MainSplitViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit

class MainSplitViewController : UISplitViewController {
    var leftViewController: UIViewController?
    var rightViewController: UIViewController?
    
    convenience init(withLeftViewController leftViewController:UIViewController,
                     rightViewController:UIViewController) {
        
        self.init(nibName: nil, bundle: nil)
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
    
        self.viewControllers = [ leftViewController, rightViewController ]
        
        self.primaryBackgroundStyle = .sidebar
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
