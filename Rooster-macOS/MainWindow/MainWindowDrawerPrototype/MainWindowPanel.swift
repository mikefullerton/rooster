//
//  MainWindowPanel.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/7/21.
//

import Cocoa
import RoosterCore

public class MainWindowPanel: NSViewController {
    class PanelView: NSView {
        override var intrinsicContentSize: CGSize {
            CGSize(width: MainWindowPanel.preferredWidth, height: NSView.noIntrinsicMetric)
        }
    }

    public static let preferredWidth: CGFloat = 200.0

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.preferredContentSize = self.view.intrinsicContentSize
    }

    override public func loadView() {
        self.view = PanelView()
    }
}
