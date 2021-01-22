//
//  TableViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import Cocoa

protocol TableViewSectionAdornmentProtocol {
    var view: NSView? { get }
    
    var height: CGFloat { get }
    
    var title: String? { get }
}

extension TableViewSectionAdornmentProtocol {
    
    var view: NSView? {
        return nil
    }
    
    var title: String? {
        return nil
    }
}
