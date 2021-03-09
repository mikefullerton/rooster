//
//  ListViewSectionAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


public struct ListViewSectionAdornment: ListViewSectionAdornmentProtocol {
    public var viewClass: AnyClass
    public let title: String?
    
    public init(withViewClass viewClass: AnyClass) {
        self.viewClass = viewClass
        self.title = nil
    }

    public init(withViewClass viewClass: AnyClass,
         title: String) {
        
        self.viewClass = viewClass
        self.title = title
    }

    public init(withTitle title: String) {
        self.viewClass = SectionHeaderView.self
        self.title = title
    }
}
