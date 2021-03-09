//
//  VerticalButtonListTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class VerticalButtonListTableCell: ListViewRowController {
    public let insets = SDKEdgeInsets.twenty
    public let spacing: CGFloat = 20

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 46.0)
    }

    override open func willDisplay(withContent content: Any?) {
        guard let tabItem = content as? VerticalTabItem else {
            return
        }

        self.label.stringValue = tabItem.title
        self.iconView.image = tabItem.icon
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true

        self.addIconView()
        self.addLabel()
    }

    public lazy var iconView: SDKImageView = {
        let imageView = SDKImageView()

        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(textStyle: .title2)

        return imageView
    }()

    public lazy var label: SDKTextField = {
        let label = SDKTextField()
        label.isEditable = false
        label.alignment = .right
        label.drawsBackground = false
        label.isBordered = false
        label.textColor = Theme(for: self.view).labelColor

        return label
    }()

    private func addIconView() {
        let view = self.iconView
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.insets.left + 15),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    private func addLabel() {
        let view = self.label
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    override open var isSelected: Bool {
        get { super.isSelected }
        set(selected) {
            super.isSelected = selected

            if selected {
                self.view.layer?.backgroundColor = SDKColor.systemBlue.cgColor
            } else {
                self.view.layer?.backgroundColor = SDKColor.clear.cgColor
            }
        }
    }
}
