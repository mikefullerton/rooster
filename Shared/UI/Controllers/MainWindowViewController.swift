//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class MainWindowViewController : EventListViewController, Loggable {
    
    static let DidChangeEvent = Notification.Name("MainWindowViewControllerDidChange")

    override func loadView() {
        super.loadView()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.title = "Rooster"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.sendSizeChangedEvent()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.sendSizeChangedEvent()
    }
    
    func sendSizeChangedEvent() {
        if self.preferredContentSize.width != 0 && self.preferredContentSize.height != 0 {
            NotificationCenter.default.post(name: Self.DidChangeEvent, object: self)
        }
    }

    override func dataModelDidReload(_ dataModel: DataModel) {
        super.dataModelDidReload(dataModel)
        DispatchQueue.main.async {
            self.sendSizeChangedEvent()
        }
    }
}
