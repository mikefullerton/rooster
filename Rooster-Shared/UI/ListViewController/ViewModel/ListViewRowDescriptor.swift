//
//  ListViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

protocol AbstractListViewRowDescriptor {
    var viewClass: AbstractListViewRowController.Type { get }
    func willDisplayView(_ view: SDKCollectionViewItem)
}

extension AbstractListViewRowDescriptor {
    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }

    var height: CGFloat {
        return self.viewClass.preferredHeight
    }
}

struct ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE: AbstractListViewRowController>: AbstractListViewRowDescriptor {
    let content: CONTENT_TYPE
    
    let eventHandler: EventHandler?
    
    init(withContent content: CONTENT_TYPE,
         eventHandler: EventHandler? = nil) {
        self.content = content
        self.eventHandler = eventHandler
    }
    
    func willDisplayView(_ view: SDKCollectionViewItem) {
        if let cell = view as? ListViewRowController<CONTENT_TYPE> {
            cell.viewWillAppear(withContent: self.content)
        }
    }
    
    var viewClass: AbstractListViewRowController.Type {
        return VIEW_TYPE.self
    }
}

struct ListViewModelContentFetcher<CONTENT_TYPE: Identifiable, VIEW_TYPE: AbstractListViewRowController> {
    
    let model:ListViewModelProtocol
    
    typealias RowType = ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE>
    
    init(model: ListViewModelProtocol) {
        self.model = model
    }
    
    public func contentForIndexPath(_ indexPath: IndexPath) -> CONTENT_TYPE? {
        if let row = self.model.row(forIndexPath: indexPath) as? ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE> {
            return row.content
        }
        
        return nil
    }
    
    func indexPath(forContent content: CONTENT_TYPE) -> IndexPath? {
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
