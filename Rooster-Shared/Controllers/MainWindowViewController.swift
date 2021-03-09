//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class MainEventListViewController: EventListViewController {
}

public class MainWindowViewController: SDKViewController {
    static let DidChangeEvent = Notification.Name("MainWindowViewControllerDidChange")

    let listViewController = MainEventListViewController()

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    lazy var visualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material =  .underWindowBackground // .titlebar //.headerView
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        return visualEffectView
    }()

    override public func loadView() {
        self.view = self.visualEffectView

        let view = self.listViewController.view

        self.addChild(self.listViewController)
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        self.title = "Rooster"
//        self.dataModelEventListener = EventKitDataModelUpdateHandler(for: self)

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.listViewController.reloadData()
        }

        self.listViewController.reloadData()
        self.preferredContentSize = self.listViewController.preferredContentSize
    }

    override public func preferredContentSizeDidChange(for viewController: NSViewController) {
        if viewController == self.listViewController {
            self.preferredContentSize = viewController.preferredContentSize
        }
    }

    func sendSizeChangedEvent() {
        if self.preferredContentSize.width != 0 && self.preferredContentSize.height != 0 {
            NotificationCenter.default.post(name: Self.DidChangeEvent, object: self)
        }
    }

    override public var preferredContentSize: NSSize {
        didSet {
            self.sendSizeChangedEvent()
        }
    }
}
