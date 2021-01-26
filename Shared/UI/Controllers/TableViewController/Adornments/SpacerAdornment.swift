//
//  SpaceAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation

struct SpacerAdornment :  TableViewSectionAdornmentProtocol {
    let preferredHeight: CGFloat
    
    init(withHeight height: CGFloat) {
        self.preferredHeight = height
    }
    
    var title: String? {
        return nil
    }

    var viewClass: AnyClass {
        return SpacerView.self
    }
    
}
