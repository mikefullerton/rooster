//
//  TableViewSectionAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

struct TableViewSectionAdornment: TableViewSectionAdornmentProtocol {
    var viewClass: AnyClass
    let height: CGFloat
    let title: String?
    
    init(withViewClass viewClass: AnyClass,
         height: CGFloat) {
        
        self.viewClass = viewClass
        self.height = height
        self.title = nil
    }

    init(withViewClass viewClass: AnyClass,
         title: String,
         height: CGFloat) {
        
        self.viewClass = viewClass
        self.height = height
        self.title = title
    }

    init(withTitle title: String,
         height: CGFloat) {
        
        self.viewClass = SectionHeaderView.self
        self.height = height
        self.title = title
    }
    
    init(withHeight height: CGFloat) {
        self.viewClass = SectionHeaderView.self
        self.height = height
        self.title = nil
    }
}
