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

public class BannerRow: ListViewRowController {
    private var date: Date?

    public struct Banner {
        let banner: String?
        let headline: String?
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkBackgroundColor = NSColor.clear

        self.addBackgroundView()
        self.addTopDividerView()
        self.addHeadlineLabel()
        self.addLabel()
        self.addBottomDividerView()
    }

    lazy var backgroundView: SDKView = {
        let view = self.createBlendingBackgroundViewWithColor(NSColor.textBackgroundColor)
        return view
    }()

    public func addBackgroundView() {
        let view = self.backgroundView
        self.view.addSubview(view)
        self.view.setFillInParentConstraints(forSubview: view)
    }

    lazy var label: SDKTextField = {
        let label = SDKTextField()
        label.textColor = Theme(for: self.view).secondaryLabelColor
        label.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false

        return label
    }()

    lazy var headlineLabel: SDKTextField = {
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

    private func addLabel() {
        let view = self.label
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func addHeadlineLabel() {
        let view = self.headlineLabel

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override public class func preferredSize(forContent content: Any?) -> CGSize {
        guard let content = content as? Banner else {
            return CGSize(width: -1, height: -1)
        }

        if content.headline != nil && content.banner != nil {
            return CGSize(width: -1, height: 42)
        } else if content.headline != nil {
            return CGSize(width: -1, height: 30)
        } else if content.banner != nil {
            return CGSize(width: -1, height: 30)
        }

        return CGSize(width: -1, height: -1)
    }

    private func updateContstraints() {
        self.headlineLabel.removeLocationContraints()
        self.label.removeLocationContraints()

        if self.headlineLabel.isHidden == false && self.label.isHidden == false {
            NSLayoutConstraint.activate([
                self.headlineLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.headlineLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -8),

                self.label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                self.label.topAnchor.constraint(equalTo: self.headlineLabel.bottomAnchor, constant: 0)
            ])
        } else if self.label.isHidden == false {
            self.view.setCenteredInParentConstraints(forSubview: self.label)
        } else if self.headlineLabel.isHidden == false {
            self.view.setCenteredInParentConstraints(forSubview: self.headlineLabel)
        }
    }

    override public func willDisplay(withContent content: Any?) {
        guard let content = content as? Banner else {
            return
        }

        self.label.stringValue = ""
        self.label.isHidden = true
        self.headlineLabel.stringValue = ""
        self.headlineLabel.isHidden = true

        if let banner = content.banner {
            self.label.stringValue = banner
            self.label.isHidden = false
        }

        if let headline = content.headline {
            self.headlineLabel.stringValue = headline
            self.headlineLabel.isHidden = false
        }

        self.updateContstraints()
    }
}
