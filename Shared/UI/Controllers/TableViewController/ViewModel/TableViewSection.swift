//
//  TableViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

struct TableViewSectionLayout {
    let rowSpacing: CGFloat
    let insets: SDKEdgeInsets
    
    static let zero = TableViewSectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
}

protocol TableViewSectionProtocol {
   
    var rows: [TableViewRowProtocol] { get }
    
    var header: TableViewSectionAdornmentProtocol? { get }
    
    var footer: TableViewSectionAdornmentProtocol? { get }
    
    var height: CGFloat { get }
 
    var layout: TableViewSectionLayout { get }
}

extension TableViewSectionProtocol {
    
    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
    
    var rowCount: Int {
        return self.rows.count
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return nil
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return nil
    }
    
    var height: CGFloat {
        
        var height: CGFloat = 0
        
        if let header = self.header {
            height += header.preferredHeight
        }
        
        if let footer = self.footer {
            height += footer.preferredHeight
        }
        
        for row in self.rows {
            height += row.height
        }
        
        height += self.layout.rowSpacing * CGFloat(self.rowCount)
        
        return height
    }
    
    var layout: TableViewSectionLayout {
        return TableViewSectionLayout.zero
    }
}

struct TableViewSection<ContentType, ViewType> : TableViewSectionProtocol
            where ViewType: SDKCollectionViewItem, ViewType: TableViewRowCell {
    
    let rows: [TableViewRowProtocol]
    let header: TableViewSectionAdornmentProtocol?
    let footer: TableViewSectionAdornmentProtocol?
    let layout: TableViewSectionLayout
    
    init(withRowData rows:[ContentType],
         layout: TableViewSectionLayout = TableViewSectionLayout.zero,
         header: TableViewSectionAdornmentProtocol? = nil,
         footer: TableViewSectionAdornmentProtocol? = nil) {
        
        self.layout = layout
        
        self.rows = rows.map { TableViewRow<ContentType, ViewType>(withData: $0) }
        self.header = header
        self.footer = footer
    }
    
    var rowCount: Int {
        return self.rows.count
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
}
