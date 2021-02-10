//
//  ListViewSectionAdornmentProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol ListViewAdornmentView {
    func viewWillAppear(withContent content: ListViewSectionAdornmentProtocol)
    
    static var preferredHeight: CGFloat { get }
}

protocol ListViewSectionAdornmentProtocol {
    var cellReuseIdentifer: String { get }
    
    var viewClass: AnyClass { get }
    
    var preferredHeight: CGFloat { get }
    
    var title: String? { get }
}

extension ListViewSectionAdornmentProtocol {
      
    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }
    
    var preferredHeight: CGFloat {
        if let adornmentViewClass = self.viewClass as? ListViewAdornmentView.Type {
            return adornmentViewClass.preferredHeight
        }
        
        return 24
    }
    
    func willDisplayView(_ view: ListViewAdornmentView) {
        view.viewWillAppear(withContent: self)
    }
}
