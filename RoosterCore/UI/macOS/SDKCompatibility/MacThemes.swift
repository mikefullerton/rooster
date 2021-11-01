//
//  MacThemes.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation

import Cocoa

// swiftlint:disable identifier_name

public func Theme(for view: Any?) -> ThemeProtocol {
    if  NSAppearance.current.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
        return LightTheme()
    } else {
        return DarkTheme()
    }
}

public struct LightTheme: ThemeProtocol {
    public var windowBackgroundColor: SDKColor { SDKColor.systemGray }

    public var groupBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    public var borderColor: SDKColor { SDKColor.separatorColor }

    public var preferencesViewColor: SDKColor { SDKColor.systemGray }

    public var preferencesContentViewColor: SDKColor { SDKColor.white }

    public var timeRemainingBackgroundColor: SDKColor { SDKColor.gray }

    public var labelColor: SDKColor { SDKColor.labelColor }

    public var secondaryLabelColor: SDKColor { SDKColor.secondaryLabelColor }

    public var listViewCellBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    public var disabledControlColor: SDKColor { SDKColor.controlColor.withSystemEffect(.disabled) }

//    var blurEffect: UIBlurEffect { UIBlurEffect(style: .systemThinMaterial) }

    public var tertiaryLabelColor: SDKColor { SDKColor.tertiaryLabelColor }

    public var userChosenHighlightColor: SDKColor { NSColor.selectedControlColor }

    public var seperatorColor: SDKColor { SDKColor.separatorColor }
}

public struct DarkTheme: ThemeProtocol {
    public var windowBackgroundColor: SDKColor { SDKColor.systemGray }

    public var groupBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    public var borderColor: SDKColor { SDKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) }

    public var preferencesViewColor: SDKColor { SDKColor.systemGray }

    public var preferencesContentViewColor: SDKColor { SDKColor.clear }

    public var timeRemainingBackgroundColor: SDKColor { SDKColor.gray }

    public var labelColor: SDKColor { SDKColor.labelColor }

    public var secondaryLabelColor: SDKColor { SDKColor.secondaryLabelColor }

    public var listViewCellBackgroundColor: SDKColor { SDKColor.windowBackgroundColor }

    public var disabledControlColor: SDKColor { SDKColor.controlColor.withSystemEffect(.disabled) }

    public var tertiaryLabelColor: SDKColor { SDKColor.tertiaryLabelColor }

    public var userChosenHighlightColor: SDKColor { NSColor.selectedControlColor }

    public var seperatorColor: SDKColor { SDKColor.separatorColor }

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

// this is just here to shut the linter up about the file_name
private enum MacThemes {
}
