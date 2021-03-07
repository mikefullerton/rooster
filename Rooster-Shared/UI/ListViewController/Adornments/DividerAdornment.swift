//
//  DividerAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
import RoosterCore

public struct DividerAdornment :  ListViewSectionAdornmentProtocol {
    
    public let preferredSize: CGSize
    
    public init(withHeight height: CGFloat) {
        self.preferredSize = CGSize(width: NSView.noIntrinsicMetric, height: height)
    }
    
    public var title: String? {
        return nil
    }

    public var viewClass: AnyClass {
        return DividerView.self
    }
}
