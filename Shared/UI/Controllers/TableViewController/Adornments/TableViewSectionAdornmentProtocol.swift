//
//  TableViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol TableViewSectionAdornmentProtocol {
    var viewClass: AnyClass { get }
    
    var height: CGFloat { get }
    
    var title: String? { get }
}

extension TableViewSectionAdornmentProtocol {
    
//    var view: SDKView? {
//        return nil
//    }
//
//    var title: String? {
//        return nil
//    }
}
