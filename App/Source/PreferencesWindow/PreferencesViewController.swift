//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class PreferencesViewController : UIViewController {
    
    let popoverWidth: CGFloat = 400
    
    var calculatedSize: CGSize {
        
        
        return CGSize(width: self.popoverWidth, height: 700)
    }
}
