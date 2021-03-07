//
//  ListViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

public struct ListViewSectionLayout {
    public let rowSpacing: CGFloat
    public let insets: SDKEdgeInsets
    
    public static let zero = ListViewSectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
}

public struct ListViewSectionDescriptor {
    public let rows: [AbstractListViewRowDescriptor]
    public let header: ListViewSectionAdornmentProtocol?
    public let footer: ListViewSectionAdornmentProtocol?
    public let layout: ListViewSectionLayout
    
    public init(withRows rows:[AbstractListViewRowDescriptor],
         layout: ListViewSectionLayout = ListViewSectionLayout.zero,
         header: ListViewSectionAdornmentProtocol? = nil,
         footer: ListViewSectionAdornmentProtocol? = nil) {
        
        self.layout = layout
        
        self.rows = rows
        self.header = header
        self.footer = footer
    }

    public func row(forIndex index: Int) -> AbstractListViewRowDescriptor? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
    
    public var rowCount: Int {
        return self.rows.count
    }
        
    public var size: CGSize {
        
        if self.rowCount == 0 {
            return CGSize.zero
        }
        
        var size = CGSize.zero
        
        if let header = self.header {
            size.height += header.preferredSize.height
        }
        
        if let footer = self.footer {
            size.height += footer.preferredSize.height
        }
        
        for row in self.rows {
            size.height += row.size.height
        }
        
        size.height += self.layout.rowSpacing * (CGFloat(self.rowCount) - 1)
        
        return size
    }
}
