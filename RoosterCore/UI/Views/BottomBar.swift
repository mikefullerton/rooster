//
//  BottomBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class BottomBar: BlurView {
    public let preferredHeight: CGFloat = 60
    public let insets = SDKEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    public let buttonSpacing: CGFloat = 10.0
    public let buttonSize = CGSize(width: 100, height: 60)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addDoneButton()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func addLeftButton(title: String) -> SDKButton {
        let button = self.leftButton
        button.title = title

        self.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left)
        ])

        return button
    }

    public lazy var leftButton: SDKButton = {
        SystemButton(title: "")
    }()

    public func addCancelButton() -> SDKButton {
        let button = self.cancelButton
        self.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.doneButton.leadingAnchor, constant: -self.buttonSpacing)
        ])

        return button
    }

    public lazy var cancelButton: SDKButton = {
        SystemButton(title: "Cancel")
    }()

    public lazy var doneButton: SDKButton = {
        let view = SystemButton(title: "Done")
        view.keyEquivalent = "\r"
        return view
    }()

    private func addDoneButton() {
        let button = self.doneButton
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.left)
        ])
    }

    public func addToView(_ view: SDKView) {
        view.addSubview(self)

        var frame = self.bounds
        frame.size.height = self.preferredHeight
        self.frame = frame

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    override open var intrinsicContentSize: CGSize {
        CGSize(width: SDKView.noIntrinsicMetric, height: self.preferredHeight)
    }
}
