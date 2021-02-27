//
//  iOSThemes.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import UIKit

func Theme(for traitEnvironment: UITraitEnvironment) -> ThemeProtocol {
    let traitCollection = traitEnvironment.traitCollection
    if traitCollection.userInterfaceStyle == .light {
        return LightTheme()
    } else {
        return DarkTheme()
    }
}

struct LightTheme : ThemeProtocol {
    var windowBackgroundColor: UIColor { UIColor.systemGray6 }
    
    var groupBackgroundColor: UIColor { UIColor.systemGroupedBackground }
    
    var borderColor: UIColor { UIColor.separator }
    
    var preferencesViewColor: UIColor { UIColor.systemGray6 }
    
    var preferencesContentViewColor: UIColor { UIColor.systemGray3 }
    
    var timeRemainingBackgroundColor: UIColor { UIColor.systemGray6 }
    
    var labelColor : UIColor { UIColor.label }
    
    var secondaryLabelColor: UIColor { UIColor.secondaryLabel }
    
    var listViewCellBackgroundColor: UIColor { UIColor.systemGroupedBackground }

    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }

}

struct DarkTheme : ThemeProtocol {
    var windowBackgroundColor: UIColor { UIColor.systemBackground }
    
    var groupBackgroundColor: UIColor { UIColor.systemBackground }
    
    var borderColor: UIColor { UIColor.separator }
    
    var preferencesViewColor: UIColor { UIColor.systemBackground }
    
    var preferencesContentViewColor: UIColor { UIColor.systemBackground }
    
    var timeRemainingBackgroundColor: UIColor { UIColor.systemBackground }

    var labelColor : UIColor { UIColor.label }
    
    var secondaryLabelColor: UIColor { UIColor.secondaryLabel }

    var listViewCellBackgroundColor: UIColor { self.windowBackgroundColor }

    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }
}

