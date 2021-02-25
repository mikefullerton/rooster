//
//  ListViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

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

