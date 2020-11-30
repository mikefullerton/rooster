//
//  DividerAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
import UIKit

struct DividerAdornment :  TableViewSectionAdornmentProtocol {
    
    let height: CGFloat
    
    init(withHeight height: CGFloat) {
        self.height = height
    }
    
    var title: String? {
        return nil
    }

    var view: UIView? {
        return DividerView();
    }
}
