//
//  MenuBarItem.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/31/21.
//

import Foundation
import AppKit

class MenuBarItem: Loggable, DataModelAware, AppControllerAware {
    
    static let defaultImageSize = CGSize(width: 26, height: 26)
    private var reloader: DataModelReloader? = nil
    
    init() {
        self.reloader = DataModelReloader(for: self)
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    var buttonImage: NSImage? {
        didSet {
            if let button = self.button {
                if let image = self.buttonImage {
                    button.image = image
                } else {
                    button.image = nil
                }
            }
        }
    }
    
    var prefs: MenuBarPreferences {
        return self.preferencesController.menuBarPreferences
    }
    
    var contentTintColor: NSColor? {
        get {
            if let button = self.button,
                let color = button.contentTintColor {
                return color
            }
            return nil
        }
        set(color) {
            if let button = self.button {
                return button.contentTintColor = color
            }
        }
    }
    
    var button: NSButton? {
        if let button = self.statusBarItem.button {
            return button
        }
        
        return nil
    }
    
    var buttonTitle: String {
        get {
            if let button = self.button {
                return button.title
            }
            return ""
        }
        set(title) {
            if let button = self.button {
                return button.title = title
            }
        }
    }
    
    func visibilityDidChange(toVisible visible: Bool) {
        
    }
    
    lazy var statusBarItem: NSStatusItem = {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = statusBarItem.button {
            button.image = self.buttonImage
            button.action = #selector(buttonClicked(_:))
            button.target = self
            button.imagePosition = .imageLeading
        }
        
        return statusBarItem
    }()
    
    var isVisible: Bool {
        get {
            return self.statusBarItem.isVisible
        }
        
        set(visible) {
            self.statusBarItem.isVisible = visible
            self.visibilityDidChange(toVisible: visible)
        }
    }
    
    @objc func buttonClicked(_ sender: AnyObject?) {
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
    }
}
