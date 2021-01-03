//
//  TableViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewSectionAdornmentProtocol {
    var view: UIView? { get }
    
    var height: CGFloat { get }
    
    var title: String? { get }
}

extension TableViewSectionAdornmentProtocol {
    
    var view: UIView? {
        return nil
    }
    
    var title: String? {
        return nil
    }
}
