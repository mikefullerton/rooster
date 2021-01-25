//
//  SectionHeaderView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class SectionHeaderView : BlurView, TableViewAdornmentView {
    
    lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.systemFontSize)
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

