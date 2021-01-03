//
//  TableViewRowCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/2/21.
//

import Foundation

protocol TableViewRowCell {
    associatedtype DataType
    
    static var cellHeight: CGFloat { get }
 
    func configureCell(withData data: DataType, indexPath: IndexPath, isSelected: Bool)
}
