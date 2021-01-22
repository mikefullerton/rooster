//
//  Theme.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import Cocoa

protocol ThemeProtocol {
    var windowBackgroundColor: NSColor { get }
    
    var groupBackgroundColor: NSColor { get }
    
    var borderColor: NSColor { get }
    
    var preferencesViewColor: NSColor { get }
    
    var preferencesContentViewColor: NSColor { get }
    
    var timeRemainingBackgroundColor: NSColor { get }
    
    var labelColor : NSColor { get }
    
    var secondaryLabelColor: NSColor { get }
    
    var tableViewCellBackgroundColor: NSColor { get }
    
    var disabledControlColor: NSColor { get }
    
//    var blurEffect: NSBlurEffect { get }
}

func Theme(for view: NSView) -> ThemeProtocol {
    let appearance = view.effectiveAppearance
    if appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
        return LightTheme()
    } else {
        return DarkTheme()
    }
}

struct LightTheme : ThemeProtocol {
    var windowBackgroundColor: NSColor { NSColor.systemGray }
    
    var groupBackgroundColor: NSColor { NSColor.windowBackgroundColor }
    
    var borderColor: NSColor { NSColor.separatorColor }
    
    var preferencesViewColor: NSColor { NSColor.systemGray }
    
    var preferencesContentViewColor: NSColor { NSColor.systemGray }
    
    var timeRemainingBackgroundColor: NSColor { NSColor.gray }
    
    var labelColor : NSColor { NSColor.labelColor }
    
    var secondaryLabelColor: NSColor { NSColor.secondaryLabelColor }
    
    var tableViewCellBackgroundColor: NSColor { NSColor.windowBackgroundColor }

    var disabledControlColor: NSColor { NSColor.lightGray }

//    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }

}

struct DarkTheme : ThemeProtocol {
    var windowBackgroundColor: NSColor { NSColor.systemGray }
    
    var groupBackgroundColor: NSColor { NSColor.windowBackgroundColor }
    
    var borderColor: NSColor { NSColor.separatorColor }
    
    var preferencesViewColor: NSColor { NSColor.systemGray }
    
    var preferencesContentViewColor: NSColor { NSColor.systemGray }
    
    var timeRemainingBackgroundColor: NSColor { NSColor.gray }
    
    var labelColor : NSColor { NSColor.labelColor }
    
    var secondaryLabelColor: NSColor { NSColor.secondaryLabelColor }
    
    var tableViewCellBackgroundColor: NSColor { NSColor.windowBackgroundColor }

    var disabledControlColor: NSColor { NSColor.lightGray }

//    var windowBackgroundColor: NSColor { NSColor.systemBackground }
//
//    var groupBackgroundColor: NSColor { NSColor.systemBackground }
//
//    var borderColor: NSColor { NSColor.separator }
//
//    var preferencesViewColor: NSColor { NSColor.systemBackground }
//
//    var preferencesContentViewColor: NSColor { NSColor.systemBackground }
//
//    var timeRemainingBackgroundColor: NSColor { NSColor.systemBackground }
//
//    var labelColor : NSColor { NSColor.label }
//
//    var secondaryLabelColor: NSColor { NSColor.secondaryLabel }
//
//    var tableViewCellBackgroundColor: NSColor { self.windowBackgroundColor }
//
//    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }
}
