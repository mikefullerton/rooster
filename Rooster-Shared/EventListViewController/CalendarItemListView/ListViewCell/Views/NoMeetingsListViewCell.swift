//
//  NoMeetingsListViewCell.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Cocoa
import Foundation
import RoosterCore

public struct NoMeetingsModelObject {
    let date: Date
}

open class NoMeetingsListViewCell: ListViewRowController {
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.sdkLayer.cornerRadius = 6.0
        self.view.sdkLayer.borderWidth = 0.5
        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
        self.view.sdkLayer.masksToBounds = true

//        self.view.sdkBackgroundColor = SDKColor.textBackgroundColor

        self.addHighlightBackgroundView()

        self.addNoMoreMeetingsView()

        self.preferredContentSize = Self.preferredSize(forContent: nil)
    }

    private lazy var noMoreMeetingsView: SDKTextField = {
        let view = SDKTextField()

        view.textColor = Theme(for: self.view).secondaryLabelColor
        view.font = SDKFont.systemFont(ofSize: SDKFont.smallSystemFontSize)
        view.isEditable = false
        view.isBordered = false
        view.drawsBackground = false
        view.alignment = .center

        return view
    }()

    private func addNoMoreMeetingsView() {
        let view = self.noMoreMeetingsView

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 50)
    }

    override open func willDisplay(withContent content: Any?) {
        guard let content = content as? NoMeetingsModelObject else {
            return
        }

        if content.date.isToday {
            self.noMoreMeetingsView.stringValue = "All clear for Today!! 🎉"
        } else {
            self.noMoreMeetingsView.stringValue = "Nothing scheduled for \(content.date.niceDateString)"
        }
    }
}
