//
//  VerticalButtonBarTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import Cocoa

class VerticalButtonBarTableCell : NSCollectionViewItem, TableViewRowCell {
    
    typealias DataType = VerticalTabItem
    
    let insets = NSEdgeInsets.twenty
    
    static var cellHeight: CGFloat {
        return 40.0
    }
 
    func configureCell(withData data: DataType, indexPath: IndexPath, isSelected: Bool) {
        self.label.stringValue = data.title
    }

    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        
        self.addLabel()
    }
    
    lazy var label : NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.alignment = .right
        label.drawsBackground = false
        label.isBordered = false
        label.textColor = Theme(for: self.view).secondaryLabelColor
        
        return label
    }()

    
    func addLabel() {
        
        let view = label
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.insets.left),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    override var isSelected: Bool {
        get { return super.isSelected }
        set(selected) {
            super.isSelected = selected
            
            if selected {
                self.view.layer?.backgroundColor = NSColor.systemBlue.cgColor
            } else {
                self.view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }

    
}
