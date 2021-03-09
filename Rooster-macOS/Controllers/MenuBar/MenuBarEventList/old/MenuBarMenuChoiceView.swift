//
//  MenuBarMenuChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/10/21.
//

import Cocoa
import Foundation
import RoosterCore

open class MenuBarMenuChoiceView: NSView {
    private let completion: () -> Void

    public init(title: String, systemSymbolName: String?, completion: @escaping () -> Void) {
        self.completion = completion
        super.init(frame: CGRect.zero)

        self.addLabelView()
        self.addIconView()

        if let symbolName = systemSymbolName {
            self.iconView.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: symbolName)
        }

        self.labelView.stringValue = title
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var labelView: SDKTextField = {
        let view = SDKTextField()

        view.textColor = Theme(for: self).labelColor
        view.font = SDKFont.systemFont(ofSize: SDKFont.systemFontSize)
        view.isEditable = false
        view.isBordered = false
        view.drawsBackground = false
        view.alignment = .left

        return view
    }()

    lazy var iconView: SDKImageView = {
        let imageView = SDKImageView()

//        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(textStyle: .title2)

        return imageView
    }()

    func addIconView() {
        let view = self.iconView
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    func addLabelView() {
        let view = self.labelView

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

//    override open func setConstraintsForHighlightBackgroundView() {
//        if let view = self.highlightBackgroundView {
//            view.sdkLayer.cornerRadius = 4.0
//            view.sdkLayer.masksToBounds = true
//
//            NSLayoutConstraint.activate([
//                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 4.0),
//                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -4.0),
//                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 2.0),
//                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -2.0)
//            ])
//        }
//    }
}
