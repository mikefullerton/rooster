//
//  ListViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

public protocol ListViewAdornmentView {
    func viewWillAppear(withContent content: ListViewSectionAdornmentProtocol)
    
    static var preferredSize: CGSize { get }
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
        if let adornmentViewClass = self.viewClass as? ListViewAdornmentView.Type {
            return adornmentViewClass.preferredSize
        }
        
        return CGSize(width: NSView.noIntrinsicMetric, height:24)
    }
    
    public func willDisplayView(_ view: ListViewAdornmentView) {
        view.viewWillAppear(withContent: self)
    }
}
