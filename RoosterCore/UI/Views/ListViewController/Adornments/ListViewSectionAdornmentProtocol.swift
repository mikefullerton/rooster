//
//  ListViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


public protocol ListViewAdornmentView {
    func viewWillAppear(withContent content: ListViewSectionAdornmentProtocol)
    
    static func preferredSize(forContent content: Any?) -> CGSize
}

public protocol ListViewSectionAdornmentProtocol {
    var cellReuseIdentifer: String { get }
    
    var viewClass: AnyClass { get }
    
    var preferredSize: CGSize { get }
    
    var title: String? { get }
}

extension ListViewSectionAdornmentProtocol {
      
    public var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }
    
    public var preferredSize: CGSize {
//        if let adornmentViewClass = self.viewClass as? ListViewAdornmentView.Type {
//            return adornmentViewClass.preferredSize(forContent: content)
//        }
        
        return CGSize(width: -1, height:24)
    }
    
    public func willDisplayView(_ view: ListViewAdornmentView) {
        view.viewWillAppear(withContent: self)
    }
}
