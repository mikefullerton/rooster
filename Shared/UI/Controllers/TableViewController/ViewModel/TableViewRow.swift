//
//  TableViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol TableViewRowProtocol  {
    var cellReuseIdentifer: String { get }

    var height: CGFloat { get }

    var cellClass: SDKCollectionViewItem.Type { get }

    func willDisplay(cell: SDKCollectionViewItem, atIndexPath indexPath: IndexPath, isSelected: Bool)
}

struct TableViewRow<DataType, ViewType> : TableViewRowProtocol
            where ViewType: SDKCollectionViewItem, ViewType: TableViewRowCell {
    
    let data: DataType
    
    init(withData data: DataType) {
        self.data = data
    }
    
    func willDisplay(cell: SDKCollectionViewItem, atIndexPath indexPath: IndexPath, isSelected: Bool) {
        
        if let typedCell = cell as? ViewType,
           let data = self.data as? ViewType.DataType {
            
            typedCell.configureCell(withData: data, indexPath: indexPath, isSelected: isSelected)
        }
    }

    var cellClass: SDKCollectionViewItem.Type {
        return ViewType.self
    }

    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.cellClass)"
    }

    var height: CGFloat {
        if let rowCell = self.cellClass as? ViewType.Type {
            return rowCell.cellHeight
        }
        
        return 24
    }

}


 
