//
//  Theme.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

protocol ThemeProtocol {
    var windowBackgroundColor: SDKColor { get }
    
    var groupBackgroundColor: SDKColor { get }
    
    var borderColor: SDKColor { get }
    
    var preferencesViewColor: SDKColor { get }
    
    var preferencesContentViewColor: SDKColor { get }
    
    var timeRemainingBackgroundColor: SDKColor { get }
    
    var labelColor : SDKColor { get }
    
    var secondaryLabelColor: SDKColor { get }
    
    var listViewCellBackgroundColor: SDKColor { get }
    
    var disabledControlColor: SDKColor { get }

    #if os(macOS)


    #else

    var blurEffect: UIBlurEffect { get }

    #endif
}



