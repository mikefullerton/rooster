//
//  CalendarToolbarView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol CalendarToolbarViewDelegate: AnyObject {
    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int)
}

public class CalendarToolbarView: TopBar {
    public weak var delegate: CalendarToolbarViewDelegate?

    override public var preferredHeight: CGFloat {
        60.0
    }

    init() {
        super.init(frame: CGRect.zero)
        self.addToolbar()
    }

    @objc func segmentedControllerDidChange(_ sender: SDKSegmentedControl) {
        if let delegate = self.delegate {
            delegate.calendarToolbarView(self, didChangeSelectedIndex: sender.selectedSegment)
        }
    }

    lazy var toolbar: SDKSegmentedControl = {
        var view = SDKSegmentedControl()
        view.segmentCount = 2
        view.setLabel("Calendars", forSegment: 0)
        view.setLabel("Delegate Calendars", forSegment: 1)
        view.selectedSegment = 0
        view.target = self
        view.action = #selector(segmentedControllerDidChange(_:))
        view.segmentDistribution = .fillEqually
        return view
    }()

    private func addToolbar() {
        let toolbar = self.toolbar

        self.addSubview(toolbar)

        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toolbar.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
