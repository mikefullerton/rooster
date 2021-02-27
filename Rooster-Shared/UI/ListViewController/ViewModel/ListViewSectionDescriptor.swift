//
//  ListViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

struct ListViewSectionLayout {
    let rowSpacing: CGFloat
    let insets: SDKEdgeInsets
    
    static let zero = ListViewSectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
}

struct ListViewSectionDescriptor {
    let rows: [AbstractListViewRowDescriptor]
    let header: ListViewSectionAdornmentProtocol?
    let footer: ListViewSectionAdornmentProtocol?
    let layout: ListViewSectionLayout
    
    init(withRows rows:[AbstractListViewRowDescriptor],
         layout: ListViewSectionLayout = ListViewSectionLayout.zero,
         header: ListViewSectionAdornmentProtocol? = nil,
         footer: ListViewSectionAdornmentProtocol? = nil) {
        
        self.layout = layout
        
        self.rows = rows
        self.header = header
        self.footer = footer
    }

    func row(forIndex index: Int) -> AbstractListViewRowDescriptor? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
    
    var rowCount: Int {
        return self.rows.count
    }
        
    var height: CGFloat {
        
        if self.rowCount == 0 {
            return 0.0
        }
        
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
        
        height += self.layout.rowSpacing * (CGFloat(self.rowCount) - 1)
        
        return height
    }
}
