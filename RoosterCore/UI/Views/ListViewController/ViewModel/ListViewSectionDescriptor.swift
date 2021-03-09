//
//  ListViewSection.swift
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
        
    public var height: CGFloat {
        
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
