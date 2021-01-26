//
//  TableViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol TableViewRowCell {
    associatedtype ContentType
    
    static var preferredHeight: CGFloat { get }
 
    func viewWillAppear(withContent content: ContentType)
}

protocol TableViewRowProtocol  {
    var cellReuseIdentifer: String { get }

    var height: CGFloat { get }

    var viewClass: SDKCollectionViewItem.Type { get }

    func willDisplayView(_ view: SDKCollectionViewItem)
}

struct TableViewRow<ContentType, ViewType> : TableViewRowProtocol
            where ViewType: SDKCollectionViewItem, ViewType: TableViewRowCell {
    
    let data: ContentType
    
    init(withData data: ContentType) {
        self.data = data
    }
    
    func willDisplayView(_ view: SDKCollectionViewItem) {
        
        if let typedCell = view as? ViewType,
           let content = self.data as? ViewType.ContentType {
            
            typedCell.viewWillAppear(withContent: content)
        }
    }

    var viewClass: SDKCollectionViewItem.Type {
        return ViewType.self
    }

    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }

    var height: CGFloat {
        if let rowCell = self.viewClass as? ViewType.Type {
            return rowCell.preferredHeight
        }
        
        return 24
    }
}


 
