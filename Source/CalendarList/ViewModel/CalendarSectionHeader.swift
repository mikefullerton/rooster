//
//  CalendarSectionHeader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct CalendarSectionHeader :  TableViewSectionAdornmentProtocol {
    
    private let source: String
    
    init(withSource source: String) {
        self.source = source
    }
    
    var title: String? {
        return self.source
    }
    
    var height: CGFloat {
        return 24
    }
}

