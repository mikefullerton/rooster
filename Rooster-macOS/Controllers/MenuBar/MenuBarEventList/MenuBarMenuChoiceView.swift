//
//  MenuBarMenuChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/10/21.
//

import Foundation
import RoosterCore
import Cocoa

struct MenuBarMenuChoice {
    let selector: Selector
    let title: String
    let systemSymbolName: String?
}

class MenuBarMenuChoiceView : ListViewRowController<MenuBarMenuChoice>, MenuBarItem {
 
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.sdkLayer.cornerRadius = 6.0
//        self.view.sdkLayer.borderWidth = 0.5
//        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
//        self.view.sdkLayer.masksToBounds = true

        self.isHighlightable = true
        
        self.addLabelView()
        self.addIconView()
    }

    private lazy var labelView: SDKTextField = {
        let view = SDKTextField()
        
        view.textColor = Theme(for: self.view).labelColor
        view.font = SDKFont.systemFont(ofSize: SDKFont.systemFontSize)
        view.isEditable = false
        view.isBordered = false
        view.drawsBackground = false
        view.alignment = .left
        
        return view
    }()

    lazy var iconView : SDKImageView = {
        let imageView = SDKImageView()
        
//        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(textStyle: .title2)
        
        return imageView
    }()
    
    func addIconView() {
        let view = self.iconView
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    func addLabelView() {
        
        let view = self.labelView
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    open class override func preferredSize(forContent content: Any?) -> CGSize {
        return CGSize(width: -1, height:40)
    }

    var choice: MenuBarMenuChoice?
    
    override func viewWillAppear(withContent content: MenuBarMenuChoice) {
        
        if let symbolName = content.systemSymbolName {
            self.iconView.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: symbolName)
        }
            
        self.labelView.stringValue = content.title
        
        self.choice = content
    }
    
    func menuItemWasSelected() {
        if let choice = self.choice {
            NSApplication.shared.sendAction(choice.selector, to: nil, from: self)
        }
    }

    
    override func setConstraintsForHighlightBackgroundView() {

        if let view = self.highlightBackgroundView {
            
            view.sdkLayer.cornerRadius = 4.0
            view.sdkLayer.masksToBounds = true
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 4.0),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -4.0),
                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 2.0),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -2.0)
            ])
        }
    }


}
