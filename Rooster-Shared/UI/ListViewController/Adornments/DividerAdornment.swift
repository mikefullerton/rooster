//
//  DividerAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
import RoosterCore

struct DividerAdornment :  ListViewSectionAdornmentProtocol {
    
    let preferredHeight: CGFloat
    
    init(withHeight height: CGFloat) {
        self.preferredHeight = height
    }
    
    var title: String? {
        return nil
    }

    var viewClass: AnyClass {
        return DividerView.self
    }
}
