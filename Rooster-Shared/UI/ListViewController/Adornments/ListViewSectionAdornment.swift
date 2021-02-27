//
//  ListViewSectionAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

struct ListViewSectionAdornment: ListViewSectionAdornmentProtocol {
    var viewClass: AnyClass
    let title: String?
    
    init(withViewClass viewClass: AnyClass) {
        self.viewClass = viewClass
        self.title = nil
    }

    init(withViewClass viewClass: AnyClass,
         title: String) {
        
        self.viewClass = viewClass
        self.title = title
    }

    init(withTitle title: String) {
        self.viewClass = SectionHeaderView.self
        self.title = title
    }
}
