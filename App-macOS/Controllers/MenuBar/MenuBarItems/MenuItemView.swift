//
//  MenuItemView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

class MenuItemView : NSView, Loggable {
    
    let viewController: MenuBarEventListViewController
    
    init() {
        let viewController = MenuBarEventListViewController()
        self.viewController = viewController
        super.init(frame: CGRect.zero)
        
        let view = viewController.view
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        self.updateViewSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateViewSize() {
        self.viewController.reloadData()
        
        var frame = self.frame
        frame.size = self.viewController.preferredContentSize
        self.frame = frame
        
        self.logger.log("\(NSStringFromRect(frame))")
    }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        
        if newWindow != nil {
            self.viewController.viewWillAppear()
            
            self.updateViewSize()
            self.needsDisplay = true

        } else {
            self.viewController.viewWillDisappear()
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if self.window != nil {
            self.viewController.viewDidAppear()
            self.needsDisplay = true
        } else {
            self.viewController.viewDidDisappear()
        }
    }
}
