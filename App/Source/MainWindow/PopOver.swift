//
//  PopOver.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/21/20.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentPopOver(withViewController viewController: UIViewController, sender: UIView) {

        viewController.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(viewController, animated: true) {
            
        }
        
        viewController.popoverPresentationController?.sourceView = sender
        
    }
    
}
