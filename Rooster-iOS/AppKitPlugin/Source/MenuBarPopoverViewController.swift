//
//  MenuBarPopoverViewController.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import AppKit
import Foundation

class MenuBarPopoverViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    override func loadView() {
        self.view = NSView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    }
}
