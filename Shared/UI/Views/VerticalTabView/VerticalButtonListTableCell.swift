//
//  VerticalButtonListTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class VerticalButtonListTableCell : ListViewRowController<VerticalTabItem> {
    
    let insets = SDKEdgeInsets.twenty
    let spacing: CGFloat = 20
  
//    var eventHandler: EventHandler<VerticalTabItem, VerticalButtonListTableCell>?
  
    class override var preferredHeight: CGFloat {
        return 46.0
    }
 
    override func viewWillAppear(withContent content: VerticalTabItem) {
        self.label.stringValue = content.title
        self.iconView.image = content.icon
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        
        self.addIconView()
        self.addLabel()
    }
    
    lazy var iconView : SDKImageView = {
        let imageView = SDKImageView()
        
        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(textStyle: .title2)
        
        return imageView
    }()
    
    lazy var label : SDKTextField = {
        let label = SDKTextField()
        label.isEditable = false
        label.alignment = .right
        label.drawsBackground = false
        label.isBordered = false
        label.textColor = Theme(for: self.view).labelColor
        
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
                self.view.layer?.backgroundColor = SDKColor.systemBlue.cgColor
            } else {
                self.view.layer?.backgroundColor = SDKColor.clear.cgColor
            }
        }
    }

    
}
