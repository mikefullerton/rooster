//
//  Theme(self).swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import UIKit

protocol ThemeProtocol {
    var windowBackgroundColor: UIColor { get }
    
    var groupBackgroundColor: UIColor { get }
    
    var borderColor: UIColor { get }
    
    var preferencesViewColor: UIColor { get }
    
    var preferencesContentViewColor: UIColor { get }
    
    var timeRemainingBackgroundColor: UIColor { get }
    
    var labelColor : UIColor { get }
    
    var secondaryLabelColor: UIColor { get }
    
    var tableViewCellBackgroundColor: UIColor { get }
    
    var blurEffect: UIBlurEffect { get }
}


