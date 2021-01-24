//
//  VerticalButtonListTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import Cocoa

class VerticalButtonListTableCell : NSCollectionViewItem, TableViewRowCell {
    
    typealias DataType = VerticalTabItem
    
    let insets = NSEdgeInsets.twenty
    let spacing: CGFloat = 20
    
    static var cellHeight: CGFloat {
        return 46.0
    }
 
    func configureCell(withData data: DataType, indexPath: IndexPath, isSelected: Bool) {
        self.label.stringValue = data.title
        self.iconView.image = data.icon
    }

    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        
        self.addIconView()
        self.addLabel()
    }
    
    lazy var iconView : NSImageView = {
        let imageView = NSImageView()
        
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(textStyle: .title2)
        
        return imageView
    }()
    
    lazy var label : NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.alignment = .right
        label.drawsBackground = false
        label.isBordered = false
        label.textColor = Theme(for: self.view).secondaryLabelColor
        
        return label
    }()

    func addIconView() {
        let view = self.iconView
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.insets.left + 15),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    
    func addLabel() {
        let view = self.label
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60),
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
