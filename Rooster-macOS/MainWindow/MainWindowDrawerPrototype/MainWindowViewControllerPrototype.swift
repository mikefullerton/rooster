//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import AppKit
import Cocoa
#else
import UIKit
#endif

public class MainEventListViewController: EventListViewController {
}

public class MainWindowViewControllerPrototype: SDKViewController {
    public static let DidChangeEvent = Notification.Name("MainWindowViewControllerDidChange")

    public let listViewController = MainEventListViewController()

    public static let panelWidth: CGFloat = 200.0

    private var scheduleUpdateHandler = ScheduleEventListener()

//    public lazy var mainWindowPanel = MainWindowPanel()

    lazy var visualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material =  .underWindowBackground // .titlebar //.headerView
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        return visualEffectView
    }()

    override public func loadView() {
        self.view = self.visualEffectView

        self.view.autoresizesSubviews = false

        self.addListViewController()
//        self.addPanelViewController()
        self.title = "Rooster"
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.scheduleUpdateHandler = ScheduleEventListener(for: self)

        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
    //            self.preferredContentSize = self.calculatedContentSize

    //            var frame = self.listView.frame
    //            frame.size = self.listViewController.calculatedContentSize
    //            self.listView.frame = frame

    //            self.adjustPreferredContentSize()
    //            self.updateContentSizes()

                self.sendSizeChangedEvent()
                self.view.needsLayout = true
            }
        }
    }

    override public func viewWillAppear() {
        super.viewWillAppear()
//        self.adjustPreferredContentSize()
    }

    func sendSizeChangedEvent() {
//        if self.preferredContentSize.width != 0 && self.preferredContentSize.height != 0 {
            NotificationCenter.default.post(name: Self.DidChangeEvent, object: self)
//        }
    }

    lazy var listView: NSView = {
        self.listViewController.view
    }()

    func addListViewController() {
        let view = self.listView

//        let view = self.listViewController.view
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
// //            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            view.topAnchor.constraint(equalTo: self.view.topAnchor),
// //            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        ])

        self.addChild(self.listViewController)
        self.view.addSubview(view)

//        view.translatesAutoresizingMaskIntoConstraints = false

//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        self.setListViewConstraints()
    }

    func setListViewConstraints() {
//        let view = self.listView
//
//        NSLayoutConstraint.deactivate(view.constraints)
//
//        let size = self.listViewController.calculatedContentSize
//
//        let panelOffset = self.isPanelVisible ? -Self.panelWidth : 0
//
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
//            view.heightAnchor.constraint(equalToConstant: size.height),
//            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: panelOffset)
//        ])

    }

    override public func viewDidLayout() {
        super.viewDidLayout()

        if self.isPanelVisible {
            let bounds = self.view.bounds

            var listViewFrame = bounds
            listViewFrame.size.width -= Self.panelWidth
            self.listView.frame = listViewFrame

            var panelBounds = bounds
            panelBounds.size.width = Self.panelWidth
            panelBounds.origin.x = bounds.maxX - Self.panelWidth
            self.panelView.frame = panelBounds
        } else {
            self.listView.frame = self.view.bounds
        }
    }

    func setPanelViewConstraints() {
//        if self.panelView.superview != nil {
//
//            NSLayoutConstraint.deactivate(view.constraints)
//
//            NSLayoutConstraint.activate([
//                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
//                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
//                view.heightAnchor.constraint(equalToConstant: self.calculatedContentSize.height),
//                view.widthAnchor.constraint(equalToConstant: Self.panelWidth)
//            ])
//        }
    }

    var isPanelVisible: Bool {
        self.panelView.superview != nil
    }

    lazy var panelView: NSView = {
        let view = NSView()
        view.sdkBackgroundColor = NSColor.red

        return view
    }()

    func addPanelViewController() {
        self.view.addSubview(self.panelView)

//        view.translatesAutoresizingMaskIntoConstraints = false

        self.setPanelViewConstraints()
    }

//    public var preferredContentSize: NSSize {
//        get {
//            return super.preferredContentSize
//        }
//        set(size) {
//            super.preferredContentSize = size
//
// //            var frame = self.view.frame
// //            frame.size = self.preferredContentSize
// //            self.view.frame = frame
//
//            self.sendSizeChangedEvent()
//        }
//    }
//

    public var calculatedContentSize: CGSize {
        var outSize = self.listViewController.calculatedContentSize

        if self.isPanelVisible {
            outSize.width += Self.panelWidth
        }

        return outSize
    }

//    private func adjustPreferredContentSize() {
//
//        let listViewSize = self.listViewController.calculatedContentSize
//        if listViewSize == CGSize.zero {
//            return
//        }
//
// //        let panelSize = CGSize(width:Self.panelWidth, height: listViewSize.height)
//
//        let size = listViewSize
//
// //        if self.splitView.isSubviewCollapsed(self.panelView) {
// //            size.width = self.listViewController.preferredContentSize.width
// //        } else {
// //            size.width += panelSize.width
// //        }
//
// //        var panelFrame = self.panelView.frame
// //        panelFrame.size = panelSize
// //        self.panelView.frame = panelFrame
//
//        if self.preferredContentSize != size {
//            self.preferredContentSize = size
//        }
//    }

    public func updateContentSizes() {
        self.setListViewConstraints()
        self.setPanelViewConstraints()
    }

    public func toggleSplitView() {
        if self.panelView.superview == nil {
            self.addPanelViewController()
        } else {
            self.panelView.removeFromSuperview()
        }

        var frame = self.view.frame
        frame.size = self.calculatedContentSize
        self.view.frame = frame

        self.sendSizeChangedEvent()
        self.view.needsLayout = true

//        NSAnimationContext.runAnimationGroup() { context in
//            context.allowsImplicitAnimation = true
//            context.duration = 0.25
//            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

//            if self.splitView.isSubviewCollapsed(self.panelView) {
//                self.splitView.setPosition(MainWindowPanel.preferredWidth, ofDividerAt:1)
//            } else {
//                self.splitView.setPosition(0, ofDividerAt:1)
//            }
//
//            self.splitView.layoutSubtreeIfNeeded()
//        }
    }
}
