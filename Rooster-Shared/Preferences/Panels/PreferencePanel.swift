//
//  PreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import AppKit
import Foundation
import RoosterCore

open class PreferencePanel: SDKViewController, Loggable {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    public var callback: ((_ panel: PreferencePanel) -> Void)?

    public init(withCallback callback: ((_ panel: PreferencePanel) -> Void)? = nil) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.preferencesUpdateHandler.handler = { [weak self] newPrefs, oldPrefs in
            guard let self = self else {
                return
            }

            self.preferencesDidChange(newPrefs, oldPrefs)
        }
    }

    open func preferencesDidChange(_ oldPrefs: Preferences, _ newPrefs: Preferences) {
    }

    open func resetButtonPressed() {
        AppControllers.shared.preferences.preferences = Preferences.default
    }

    @objc public func wasChosen(_ sender: Any) {
        self.callback?(self)
    }

    public var buttonImage: NSImage {
        NSImage.image(withSystemSymbolName: self.buttonImageTitle,
                      accessibilityDescription: self.buttonImageTitle,
                      symbolConfiguration: NSImage.SymbolConfiguration(scale: .large))!
            .tint(color: NSColor.labelColor)
    }

    public var buttonTitle: String {
        ""
    }

    public var buttonImageTitle: String {
        ""
    }

    public var isSelected: Bool {
        get { self.toolbarButton.toggled }
        set {
            if newValue != self.toolbarButton.toggled {
                self.toolbarButton.toggled = newValue

                if newValue == true, let callback = self.callback {
                    callback(self)
                }
            }
        }
    }

    @objc func buttonPressed(_ sender: Any?) {
        self.isSelected = true
    }

    public lazy var toolbarButton: Button = {
        Button(title: self.buttonTitle,
               attributedTitle: nil,
               image: self.buttonImage,
               imagePosition: .centerTop,
               textPosition: .centerBottom,
               spacing: 4,
               target: self,
               action: #selector(buttonPressed(_:)),
               callback: nil)
    }()

    public lazy var toolBarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(self.buttonTitle))
        item.image = self.buttonImage
        item.label = self.buttonTitle
        item.title = self.buttonTitle
        item.toolTip = self.buttonTitle
        item.isBordered = false
        item.target = self
        item.action = #selector(wasChosen(_:))
        item.minSize = CGSize.noIntrinsicMetric
        item.maxSize = CGSize.noIntrinsicMetric

        assert(item.image != nil, "image is nil")
        return item
    }()
}
