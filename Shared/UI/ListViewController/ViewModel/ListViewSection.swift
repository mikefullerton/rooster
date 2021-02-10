//
//  ListViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

struct ListViewSectionLayout {
    let rowSpacing: CGFloat
    let insets: SDKEdgeInsets
    
    static let zero = ListViewSectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
}

struct ListViewSectionDescriptor {
    let rows: [AbstractViewModelRow]
    let header: ListViewSectionAdornmentProtocol?
    let footer: ListViewSectionAdornmentProtocol?
    let layout: ListViewSectionLayout
    
    init(withRows rows:[AbstractViewModelRow],
         layout: ListViewSectionLayout = ListViewSectionLayout.zero,
         header: ListViewSectionAdornmentProtocol? = nil,
         footer: ListViewSectionAdornmentProtocol? = nil) {
        
        self.layout = layout
        
        self.rows = rows
        self.header = header
        self.footer = footer
    }

    func row(forIndex index: Int) -> AbstractViewModelRow? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
    
    var rowCount: Int {
        return self.rows.count
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
}
