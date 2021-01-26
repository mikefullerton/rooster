//
//  TableViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol TableViewAdornmentView {
    func viewWillAppear(withContent content: TableViewSectionAdornmentProtocol)
    
    static var preferredHeight: CGFloat { get }
}

protocol TableViewSectionAdornmentProtocol {
    var cellReuseIdentifer: String { get }
    
    var viewClass: AnyClass { get }
    
    var preferredHeight: CGFloat { get }
    
    var title: String? { get }
}

extension TableViewSectionAdornmentProtocol {
      
    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }
    
    var preferredHeight: CGFloat {
        if let adornmentViewClass = self.viewClass as? TableViewAdornmentView.Type {
            return adornmentViewClass.preferredHeight
        }
        
        return 24
    }
    
    func willDisplayView(_ view: TableViewAdornmentView) {
        view.viewWillAppear(withContent: self)
    }
}
