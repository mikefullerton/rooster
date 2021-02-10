//
//  MacThemes.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import Cocoa

func Theme(for view: SDKView) -> ThemeProtocol {
    let appearance = view.effectiveAppearance
    if appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
        return LightTheme()
    } else {
        return DarkTheme()
    }
}

struct LightTheme : ThemeProtocol {
    var windowBackgroundColor: SDKColor { SDKColor.systemGray }
    
    var groupBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }
    
    var borderColor: SDKColor { SDKColor.separatorColor }
    
    var preferencesViewColor: SDKColor { SDKColor.systemGray }
    
    var preferencesContentViewColor: SDKColor { SDKColor.white }
    
    var timeRemainingBackgroundColor: SDKColor { SDKColor.gray }
    
    var labelColor : SDKColor { SDKColor.labelColor }
    
    var secondaryLabelColor: SDKColor { SDKColor.secondaryLabelColor }
    
    var listViewCellBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    var disabledControlColor: SDKColor { SDKColor.lightGray }

//    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }

}

struct DarkTheme : ThemeProtocol {
    var windowBackgroundColor: SDKColor { SDKColor.systemGray }
    
    var groupBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }
    
    var borderColor: SDKColor { SDKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) }
    
    var preferencesViewColor: SDKColor { SDKColor.systemGray }
    
    var preferencesContentViewColor: SDKColor { SDKColor.clear }
    
    var timeRemainingBackgroundColor: SDKColor { SDKColor.gray }
    
    var labelColor : SDKColor { SDKColor.labelColor }
    
    var secondaryLabelColor: SDKColor { SDKColor.secondaryLabelColor }
    
    var listViewCellBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    var disabledControlColor: SDKColor { SDKColor.lightGray }

//    var windowBackgroundColor: SDKColor { SDKColor.systemBackground }
//
//    var groupBackgroundColor: SDKColor { SDKColor.systemBackground }
//
//    var borderColor: SDKColor { SDKColor.separator }
//
//    var preferencesViewColor: SDKColor { SDKColor.systemBackground }
//
//    var preferencesContentViewColor: SDKColor { SDKColor.systemBackground }
//
//    var timeRemainingBackgroundColor: SDKColor { SDKColor.systemBackground }
//
//    var labelColor : SDKColor { SDKColor.label }
//
//    var secondaryLabelColor: SDKColor { SDKColor.secondaryLabel }
//
//    var listViewCellBackgroundColor: SDKColor { self.windowBackgroundColor }
//
//    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }
}
