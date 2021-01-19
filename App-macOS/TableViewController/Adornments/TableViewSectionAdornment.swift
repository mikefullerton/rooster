//
//  TableViewSectionAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import Cocoa

struct TableViewSectionAdornment: TableViewSectionAdornmentProtocol {
    let view: NSView?
    let height: CGFloat
    let title: String?
    
    init(withView view: NSView,
         height: CGFloat) {
        
        self.view = view
        self.height = height
        self.title = nil
    }

    init(withTitle title: String,
         height: CGFloat) {
        
        self.view = nil
        self.height = height
        self.title = title
    }
    
    init(withHeight height: CGFloat) {
        self.view = NSView(frame: CGRect(x:0, y:0, width:0, height:height))
        self.height = height
        self.title = nil
    }
}
