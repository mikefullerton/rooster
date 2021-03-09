//
//  SpaceAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


public struct SpacerAdornment :  ListViewSectionAdornmentProtocol {
    public let preferredHeight: CGFloat
    
    public init(withHeight height: CGFloat) {
        self.preferredHeight = height
    }
    
    public var title: String? {
        return nil
    }

    public var viewClass: AnyClass {
        return SpacerView.self
    }
    
}
