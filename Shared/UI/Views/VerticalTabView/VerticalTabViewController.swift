//
//  VerticalTabViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

struct VerticalTabItem {
    let identifier: String
    let title: String
    let icon: SDKImage?
    let view: SDKView
    let viewController: SDKViewController?
    
    init(identifier: String,
         title: String,
         icon: SDKImage?,
         view: SDKView) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.view = view
        self.viewController = nil
    }

    init(identifier: String,
         title: String,
         icon: SDKImage?,
         viewController: SDKViewController) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.viewController = viewController
        self.view = viewController.view
    }
}

protocol VerticalTabViewControllerDelegate : AnyObject {
    func verticalTabViewController(_ verticalTabViewController: VerticalTabViewController, didChangeTab tab: VerticalTabItem)
}

class VerticalTabViewController : SDKViewController, VerticalButtonListViewControllerDelegate {
    let items: [VerticalTabItem]
    
    weak var delegate: VerticalTabViewControllerDelegate?
    
    lazy var verticalButtonBarController = VerticalButtonListViewController(with: self.items)
    private var contentView: SDKView?

    let buttonBarInsets = SDKEdgeInsets.ten
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
        let view = SDKView()
        view.wantsLayer = true
        view.layer?.backgroundColor = SDKColor.clear.cgColor
        
        self.view = view
        
        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .vertical)
        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .horizontal)

        self.addButtonList()
        self.addContentContainerView()
        self.addChildViewControllers()
        
        self.verticalButtonBarController.delegate = self
    }

    lazy var contentContainerView : SDKView = {
        let view = SDKView()
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme(for: view).preferencesContentViewColor.cgColor
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self.view).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        return view
    }()

    func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController,
                                         didChooseItem item: VerticalTabItem) {
        self.setContentView(item.view)
        self.delegate?.verticalTabViewController(self, didChangeTab: item)
    }

    private func addChildViewControllers() {
        for tabItem in self.items {
            if tabItem.viewController != nil {
                self.addChild(tabItem.viewController!)
            }
        }
    }
    
    lazy var buttonListContainerView: NSView = {
       let view = NSView()
        view.wantsLayer = true
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self.view).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        view.layer?.masksToBounds = true
        
        return view
    }()
    
    private func addButtonList() {
        
        let container = self.buttonListContainerView
        self.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.buttonBarInsets.left),
            container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.buttonBarInsets.top),
            container.widthAnchor.constraint(equalToConstant:self.buttonListWidth + self.buttonBarInsets.right),
            container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])

        let controller = self.verticalButtonBarController
        
        self.addChild(controller)
        
        container.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        container.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        container.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
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
    }
    
    func setContentView(_ view: SDKView) {
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
        self.contentView = view
    }
}
