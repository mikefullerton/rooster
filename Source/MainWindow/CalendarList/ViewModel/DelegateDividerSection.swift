//
//  DelegateSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct DelegateHeaderSection : TableViewSectionProtocol {
    
    let rows:[TableViewRowProtocol] = [DelegateDividerRow(withTitle: "Delegate Calendars")]
    
    var header: TableViewSectionAdornmentProtocol? {
        return DividerAdornment(withHeight: 20)
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return DividerAdornment(withHeight: 20)
    }
}
