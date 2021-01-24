//
//  VerticalTabViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import Cocoa

struct VerticalTabItem {
    let title: String
    let icon: NSImage?
    let view: NSView
    let viewController: NSViewController?
    
    init(title: String,
         icon: NSImage?,
         view: NSView) {
        
        self.title = title
        self.icon = icon
        self.view = view
        self.viewController = nil
    }

    init(title: String,
         icon: NSImage?,
         viewController: NSViewController) {
        self.title = title
        self.icon = icon
        self.viewController = viewController
        self.view = viewController.view
    }
}

class VerticalTabViewController : NSViewController, VerticalButtonListViewControllerDelegate {
    let items: [VerticalTabItem]
    
    lazy var verticalButtonBarController = VerticalButtonListViewController(with: self.items)
    private var contentView: NSView?

    let buttonBarInsets = NSEdgeInsets.ten
    let buttonListWidth:CGFloat
    
    init(with items: [VerticalTabItem],
         buttonListWidth: CGFloat) {
        self.buttonListWidth = buttonListWidth
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.view = view
        
        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .vertical)
        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .horizontal)

        self.addButtonList()
        self.addContentContainerView()
        self.addChildViewControllers()
        
        self.verticalButtonBarController.delegate = self
    }

    lazy var contentContainerView : NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor // Theme(for: view).preferencesContentViewColor.cgColor
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self.view).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        return view
    }()

    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController,
                                         didChooseItem item: VerticalTabItem) {
        self.setContentView(item.view)
    }

    private func addChildViewControllers() {
        for tabItem in self.items {
            if tabItem.viewController != nil {
                self.addChild(tabItem.viewController!)
            }
        }
    }
    
    private func addButtonList() {
        let controller = self.verticalButtonBarController
        
        self.addChild(controller)
        
        self.view.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.buttonBarInsets.left),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.buttonBarInsets.top),
            controller.view.widthAnchor.constraint(equalToConstant:self.buttonListWidth + self.buttonBarInsets.right),
            
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])
        
        controller.view.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        controller.view.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
    }

    private func addContentContainerView() {
        let view = self.contentContainerView
        
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.verticalButtonBarController.view.trailingAnchor, constant: self.buttonBarInsets.left),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.buttonBarInsets.right),
            
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.buttonBarInsets.top),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])



//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func setContentView(_ view: NSView) {
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
            self.contentView = nil
        }
        
        self.contentContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = self.contentContainerView.bounds
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.contentContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentContainerView.bottomAnchor),

            view.leadingAnchor.constraint(equalTo: self.contentContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentContainerView.trailingAnchor),
        ])
       
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        self.contentView = view
    }
}
