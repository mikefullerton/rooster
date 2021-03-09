//
//  SinglePreferenceView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Carbon
import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

// swiftlint:disable file_types_order

open class KeyboardShortcutPreferenceView: PreferenceView<KeyboardShortcutPreferenceView> {
    public var keyboardShortcut = KeyboardShortcut() {
        didSet {
            if oldValue != self.keyboardShortcut {
                self.setter(self)
                self.refresh()
            }
        }
    }

    let insets = SDKEdgeInsets.ten

    override public var isEnabled: Bool {
        didSet { self.editView.isEnabled = isEnabled }
    }

    public init(withTitle title: String,
                updater: @escaping (_ view: KeyboardShortcutPreferenceView) -> Void,
                setter: @escaping (_ view: KeyboardShortcutPreferenceView) -> Void) {
        super.init(updater: updater, setter: setter)

        self.titleView.title = title + ":"

        self.addSubview(self.titleView,
                        constraints: [
                            Constraint(.leading),
                            Constraint(.centerY),
                            Constraint(.width, constant: 140)
                        ],
                        insets: self.insets)

        self.addSubview(self.editView,
                        constraints: [ Constraint(.afterSibling, siblingView: self.titleView), Constraint(.centerY) ],
                        insets: self.insets)

        self.addSubview(self.errorField,
                        constraints: [ Constraint(.afterSibling, siblingView: self.editView, constant: 10), Constraint(.centerY) ],
                        insets: self.insets)

//        self.sdkLayer.borderWidth = 1.0
//        self.sdkLayer.borderColor = NSColor.separatorColor.cgColor
//        self.sdkLayer.cornerRadius = 2.0

        self.editView.delegate = self
    }

    public lazy var errorField: HighlightableTextField = {
        let view = HighlightableTextField()
        view.isEditable = false
        view.textColor = NSColor.systemRed
        view.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.drawsBackground = false
        view.isBordered = false
        view.alignment = .left
        return view
    }()

    public lazy var titleView: SDKSwitch = {
        let view = SDKSwitch(target: self, action: #selector(checkboxChanged(_:)))
        return view
    }()

    lazy var editView = KeyboardListenerView()

    override public func refresh() {
        super.refresh()
        self.editView.isEnabled = self.titleView.isOn
        self.editView.refresh(withKeyboardShortcut: self.keyboardShortcut)
        self.titleView.isOn = self.keyboardShortcut.isEnabled

        self.errorField.isHidden = self.keyboardShortcut.error == 0

        if self.keyboardShortcut.error != 0 {
            switch self.keyboardShortcut.error {
            case eventHandlerAlreadyInstalledErr:
                self.errorField.stringValue = "This shortcut is already in use"

            default:
                self.errorField.stringValue = "Unable to install this shortcut \(self.keyboardShortcut.error)"
            }

            self.titleView.isOn = false
        }
    }

    @objc func checkboxChanged(_ sender: SDKSwitch) {
        self.keyboardShortcut.isEnabled = sender.isOn

        if self.keyboardShortcut.error != 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.titleView.isOn = false
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: NSView.noIntrinsicMetric, height: self.editView.intrinsicContentSize.height + 20)
    }
}

extension KeyboardShortcutPreferenceView: KeyboardListenerViewDelegate {
    public func keyboardListenerView(_ view: KeyboardListenerView, keyDownEvent event: NSEvent) {
        let keyCode = UInt32(event.keyCode)

        if let chars = event.charactersIgnoringModifiers {
            self.keyboardShortcut.set(key: chars,
                                      keyCode: keyCode,
                                      modifierFlags: event.modifierFlags)
        } else {
            var chars = ""
            switch Int(self.keyboardShortcut.keyCode) {
            case kVK_Escape:
                chars = "⎋"

            default:
                chars = ""
            }

            self.keyboardShortcut.set(key: chars,
                                      keyCode: keyCode,
                                      modifierFlags: event.modifierFlags)
        }
    }
}

public protocol KeyboardListenerViewDelegate: NSTextFieldDelegate {
    func keyboardListenerView(_ view: KeyboardListenerView, keyDownEvent event: NSEvent)
}

public class KeyboardListenerView: NSView, Highlightable {
    public weak var delegate: KeyboardShortcutPreferenceView?

    let itemSize = CGSize(width: 40, height: 40)

    let fontSize = NSFont.labelFontSize * 2

    private lazy var config = NSImage.SymbolConfiguration(pointSize: self.fontSize, weight: .regular, scale: .small)

    lazy var commandImage = NSImage.image(withSystemSymbolName: "command", accessibilityDescription: "Command Key", symbolConfiguration: config)!
    lazy var optionImage = NSImage.image(withSystemSymbolName: "option", accessibilityDescription: "Option Key", symbolConfiguration: config)!
    lazy var controlKey = NSImage.image(withSystemSymbolName: "control", accessibilityDescription: "Control Key", symbolConfiguration: config)!
    lazy var shiftKey = NSImage.image(withSystemSymbolName: "shift", accessibilityDescription: "Shift", symbolConfiguration: config)!

    public var isHighlighted = false

    public var isFailed = false

    private lazy var gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(wasClicked(_:)))

    @objc public func wasClicked(_ sender: Any) {
        self.window?.makeFirstResponder(self)
    }

    public var isEnabled = false {
        didSet {
            self.updateEnabled()
            self.updateFrame()
        }
    }

    func updateEnabled() {
//        self.imageViews.forEach { $0.isEnabled = self.isEnabled }
//        self.textField.isEnabled = self.isEnabled
    }

    lazy var imageViews = [
        HighlightableImageView(image: self.commandImage),
        HighlightableImageView(image: self.optionImage),
        HighlightableImageView(image: self.controlKey),
        HighlightableImageView(image: self.shiftKey)
    ]

    public lazy var textField: HighlightableTextField = {
        let view = HighlightableTextField()
        view.isEditable = false
        view.textColor = NSColor.selectedControlColor
        view.font = NSFont.systemFont(ofSize: self.fontSize)
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.drawsBackground = false
        view.isBordered = false
        view.alignment = .left
        view.preferredSize = CGSize(width: 20, height: NSView.noIntrinsicMetric)
        return view
    }()

    public lazy var stackView: SimpleStackView = {
        let view = SimpleStackView(direction: .horizontal, insets: SDKEdgeInsets.ten, spacing: SDKOffset(horizontal: 4, vertical: 0))

        var views: [SDKView] = []
        views.append(contentsOf: self.imageViews)
        views.append(self.textField)
        view.setContainedViews(views)
        return view
    }()

    func updateFrame() {
        if self.isFirstResponder {
            self.sdkLayer.borderColor = NSColor.selectedControlColor.cgColor
            self.sdkLayer.borderWidth = 2.0
        } else {
            self.sdkLayer.borderColor = nil
            self.sdkLayer.borderWidth = 0
        }
    }

    public var isFirstResponder = false {
        didSet {
            self.updateFrame()
        }
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    private func setup() {
        self.sdkLayer.cornerRadius = 2.0

        self.imageViews.forEach { $0.normalColor = NSColor.controlColor }

        self.addSubview(self.stackView, constraints: [ .center ])
        self.isFirstResponder = false

        self.addGestureRecognizer(self.gestureRecognizer)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    override public func keyDown(with event: NSEvent) {
        super .keyDown(with: event)

        self.delegate?.keyboardListenerView(self, keyDownEvent: event)
    }

    override public var acceptsFirstResponder: Bool {
        true
    }

    override public func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        self.isFirstResponder = true
        return true
    }

    override public func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.isFirstResponder = false
        return true
    }

    public func refresh(withKeyboardShortcut keyboardShortcut: KeyboardShortcut) {
        self.isFailed = keyboardShortcut.error != 0

        self.updateEnabled()
        self.updateFrame()
        self.imageViews[0].isHighlighted = keyboardShortcut.modifierFlags.contains(.command)
        self.imageViews[1].isHighlighted = keyboardShortcut.modifierFlags.contains(.option)
        self.imageViews[2].isHighlighted = keyboardShortcut.modifierFlags.contains(.control)
        self.imageViews[3].isHighlighted = keyboardShortcut.modifierFlags.contains(.shift)

        var key = ""

        if let lastKey = keyboardShortcut.key.last {
            key = String(lastKey).uppercased()
        }

        self.textField.stringValue = key
    }

    override public var intrinsicContentSize: NSSize {
        self.stackView.intrinsicContentSize
    }
}
