//
//  ListViewRow.swift
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


public protocol AbstractListViewRowDescriptor {
    var viewClass: AbstractListViewRowController.Type { get }
    func willDisplayView(_ view: SDKCollectionViewItem)
    
    var preferredSize: CGSize { get }
}

extension AbstractListViewRowDescriptor {
    public var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }
}

public struct ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE: AbstractListViewRowController>: AbstractListViewRowDescriptor {
    public let content: CONTENT_TYPE
    
    public init(withContent content: CONTENT_TYPE) {
        self.content = content
    }
    
    public func willDisplayView(_ view: SDKCollectionViewItem) {
        if let cell = view as? ListViewRowController<CONTENT_TYPE> {
            cell.viewWillAppear(withContent: self.content)
        }
    }
    
    public var viewClass: AbstractListViewRowController.Type {
        return VIEW_TYPE.self
    }
    
    public var preferredSize: CGSize {
        self.viewClass.preferredSize(forContent: self.content)
    }
        
}

public struct ListViewModelContentFetcher<CONTENT_TYPE: Identifiable, VIEW_TYPE: AbstractListViewRowController> {
    
    public let model:ListViewModelProtocol
    
    public typealias RowType = ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE>
    
    public init(model: ListViewModelProtocol) {
        self.model = model
    }
    
    public func contentForIndexPath(_ indexPath: IndexPath) -> CONTENT_TYPE? {
        if let row = self.model.row(forIndexPath: indexPath) as? ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE> {
            return row.content
        }
        
        return nil
    }
    
    public func indexPath(forContent content: CONTENT_TYPE) -> IndexPath? {
        for (sectionIndex, section) in self.model.sections.enumerated() {
            for(soundIndex, row) in section.rows.enumerated() {
                let typedRow = row as! RowType
                if typedRow.content.id == content.id {
                    return IndexPath(item: soundIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
}
