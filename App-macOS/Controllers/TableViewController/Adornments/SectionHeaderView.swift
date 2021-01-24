//
//  SectionHeaderView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Foundation
import Cocoa

class SectionHeaderView : BlurView, TableViewAdornmentView {
    
    lazy var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false

        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])

        return titleView
    }()

    func setContents(_ contents: TableViewSectionAdornmentProtocol) {
        if contents.title != nil {
            self.titleView.stringValue = contents.title!
        } else {
            self.titleView.stringValue = ""
        }
    }
    
}

