//
//  DayBannerRow.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class DayBannerRow: ListViewRowController {
    private var date: Date?

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkBackgroundColor = NSColor.clear

        self.addBackgroundView()
        self.addTopDividerView()
        self.addTodayTomorrowLabel()
        self.addTimeLabel()
        self.addBottomDividerView()
    }

    lazy var backgroundView: SDKView = {
        let view = self.createBlendingBackgroundViewWithColor(NSColor.textBackgroundColor)
        return view
    }()

    public func addBackgroundView() {
        let view = self.backgroundView
        self.view.addSubview(view)
        view.activateFillInParentConstraints()
    }

    lazy var timeLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    lazy var todayTomorrowLabel: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).labelColor
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    func createDividerView() -> SDKView {
        let view = SDKView()
        view.sdkBackgroundColor = Theme(for: self).borderColor
        return view
    }

    private func addTopDividerView() {
        let view = self.createDividerView()
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }

    private func addBottomDividerView() {
        let view = self.createDividerView()
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }

    private func addTimeLabel() {
        let view = self.timeLabel
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func addTodayTomorrowLabel() {
        let view = self.todayTomorrowLabel

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override public class func preferredSize(forContent content: Any?) -> CGSize {
        if let date = content as? Date {
            if date.isToday || date.isTomorrow {
                return CGSize(width: -1, height: 42)
            }

            return CGSize(width: -1, height: 20)
        }

        return CGSize(width: -1, height: 20)
    }

    private func showBoth() {
        self.todayTomorrowLabel.isHidden = false
        self.timeLabel.isHidden = false
        self.todayTomorrowLabel.deactivatePositionalContraints()
        self.timeLabel.deactivatePositionalContraints()

        NSLayoutConstraint.activate([
            self.todayTomorrowLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.todayTomorrowLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -8),

            self.timeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            self.timeLabel.topAnchor.constraint(equalTo: self.todayTomorrowLabel.bottomAnchor, constant: 0)
        ])
    }

    private func showDateOnly() {
        self.todayTomorrowLabel.deactivatePositionalContraints()
        self.timeLabel.deactivatePositionalContraints()

        self.todayTomorrowLabel.isHidden = true
        self.timeLabel.isHidden = false
        self.timeLabel.activateCenteredInSuperviewConstraints()
    }

    override public func willDisplay(withContent content: Any?) {
        guard let date = content as? Date else {
            return
        }

        self.preferredContentSize = Self.preferredSize(forContent: content)
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none)

        if date.isToday {
            self.todayTomorrowLabel.stringValue = "Today"
            self.timeLabel.stringValue = formattedDate
            self.showBoth()
        } else if date.isTomorrow {
            self.todayTomorrowLabel.stringValue = "Tomorrow"
            self.todayTomorrowLabel.isHidden = false
            self.timeLabel.stringValue = formattedDate
            self.showBoth()
        } else {
            self.todayTomorrowLabel.isHidden = true
            self.timeLabel.stringValue = formattedDate
            self.showDateOnly()
        }
    }
}
