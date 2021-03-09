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

public struct VerticalTabItem {
    public let identifier: String
    public let title: String
    public let icon: SDKImage?
    public let view: SDKView
    public let viewController: SDKViewController?

    public init(identifier: String,
                title: String,
                icon: SDKImage?,
                view: SDKView) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.view = view
        self.viewController = nil
    }

    public init(identifier: String,
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

public protocol VerticalTabViewControllerDelegate: AnyObject {
    func verticalTabViewController(_ verticalTabViewController: VerticalTabViewController, didChangeTab tab: VerticalTabItem)
}

open class VerticalTabViewController: SDKViewController, VerticalButtonListViewControllerDelegate {
    private(set) var items: [VerticalTabItem]

    public weak var delegate: VerticalTabViewControllerDelegate?

    private lazy var verticalButtonBarController: VerticalButtonListViewController = {
        let controller = VerticalButtonListViewController()
        controller.delegate = self
        controller.preferredContentSize = CGSize(width: self.buttonListWidth, height: NSView.noIntrinsicMetric)
        return controller
    }()

    private var contentView: SDKView?

    private(set) var selectedItem: VerticalTabItem? {
        didSet {
            if let item = self.selectedItem {
                self.setContentView(item.view)
            }
        }
    }

    public let buttonBarInsets = SDKEdgeInsets.ten

    private(set) var buttonListWidth: CGFloat {
        didSet {
            self.verticalButtonBarController.preferredContentSize = CGSize(width: self.buttonListWidth, height: NSView.noIntrinsicMetric)
        }
    }

    public init(with items: [VerticalTabItem],
                buttonListWidth: CGFloat) {
        self.buttonListWidth = buttonListWidth
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    public convenience init() {
        self.init(with: [], buttonListWidth: 0)
    }

    override public init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.buttonListWidth = 0
        self.items = []
        super .init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setItems(_ items: [VerticalTabItem], buttonListWidth: CGFloat) {
        self.items = items
        self.buttonListWidth = buttonListWidth
//        self.updateContainerViewContraints()
        self.verticalButtonBarController.reloadData()
    }

    override open func loadView() {
        let view = SDKView()
        view.wantsLayer = true
        view.layer?.backgroundColor = SDKColor.clear.cgColor

        self.view = view

        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .vertical)
        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.addButtonList()
        self.addButtonListContainerView()
        self.addContentContainerView()
        self.addChildViewControllers()
    }

    public lazy var contentContainerView: SDKView = {
        let view = SDKView()
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme(for: view).preferencesContentViewColor.cgColor
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self.view).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        return view
    }()

    open func verticalButtonBarViewController(_ verticalButtonBarViewController: VerticalButtonListViewController,
                                              didChooseItem item: VerticalTabItem) {
        self.selectedItem = item
        self.delegate?.verticalTabViewController(self, didChangeTab: item)
    }

    open func verticalButtonBarViewControllerGetItems(
        _ verticalButtonBarViewController: VerticalButtonListViewController) -> [VerticalTabItem] {
        self.items
    }

//    override open func viewWillAppear() {
//        super.viewWillAppear()
//
//        if self.selectedItem == nil && !self.items.isEmpty {
//            self.verticalButtonBarController.selectedIndex = 0
//        }
//    }

    private func addChildViewControllers() {
        for tabItem in self.items where tabItem.viewController != nil {
            self.addChild(tabItem.viewController!)
        }
    }

    public lazy var buttonListContainerView: NSView = {
       let view = NSView()
        view.wantsLayer = true
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self.view).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        view.layer?.masksToBounds = true

        return view
    }()

    private func updateContainerViewContraints() {
        let container = self.buttonListContainerView

//        container.removeLocationContraints()

        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.buttonBarInsets.left),
            container.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.buttonBarInsets.top),
            container.widthAnchor.constraint(equalToConstant: 250 + self.buttonBarInsets.right),
            container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])

        container.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        container.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        container.setContentHuggingPriority(.defaultHigh, for: .vertical)
        container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func addButtonListContainerView() {
        let container = self.buttonListContainerView
        self.view.addSubview(container)

        self.updateContainerViewContraints()
    }

    private func addButtonList() {
        let container = self.buttonListContainerView
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

//        container.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
//        container.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
//        container.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func addContentContainerView() {
        let view = self.contentContainerView

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.verticalButtonBarController.view.trailingAnchor,
                                          constant: self.buttonBarInsets.left),

            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
                                           constant: -self.buttonBarInsets.right),

            view.topAnchor.constraint(equalTo: self.view.topAnchor,
                                      constant: self.buttonBarInsets.top),

            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                         constant: -self.buttonBarInsets.bottom)
        ])

//        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .vertical)
//        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setContentView(_ view: SDKView) {
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
            view.trailingAnchor.constraint(equalTo: self.contentContainerView.trailingAnchor)
        ])

//        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .vertical)
//        view.setContentCompressionResistancePriority(.windowSizeStayPut, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.contentView = view
    }
}
