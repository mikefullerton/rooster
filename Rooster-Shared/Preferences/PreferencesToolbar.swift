//
//  PreferencesToolbar.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/1/21.
//

import Foundation

import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol PreferencesToolbarDelegate: AnyObject {
    func preferencesToolbar(_ toolbar: PreferencesToolbar, panelDidChange panel: PreferencePanel)
}

public class PreferencesToolbar: SDKView {
    public weak var delegate: PreferencesToolbarDelegate?

    public let preferencePanels: [PreferencePanel]

    private lazy var toolbar: SimpleStackView = {
        let view = SimpleStackView(direction: .horizontal,
                                   insets: SDKEdgeInsets.ten,
                                   spacing: SDKOffset.zero)

        var buttons: [Button] = []

        for prefPanel in self.preferencePanels {
            buttons.append(prefPanel.toolbarButton)

            prefPanel.callback = { [weak self] panel in
                self?.panelDidChange(panel)
            }
        }

        view.setContainedViews(buttons)

        return view
    }()

    private func addToolbar() {
        let view = self.toolbar

        self.addSubview(view)

        view.activateConstraints(.centerTop)
    }

    private func addDivider() {
        let view = NSView()
        view.sdkBackgroundColor = Theme(for: self).seperatorColor

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    public private(set) var currentPreferencePanel: PreferencePanel {
        didSet {
            self.delegate?.preferencesToolbar(self, panelDidChange: self.currentPreferencePanel)
        }
    }

    public init(withPreferencePanels preferencePanels: [PreferencePanel]) {
        self.preferencePanels = preferencePanels
        self.currentPreferencePanel = self.preferencePanels[0]

        super.init(frame: CGRect.zero)

        self.addToolbar()
        self.addDivider()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func panelDidChange(_ panel: PreferencePanel) {
        self.currentPreferencePanel = panel
    }

    override public var intrinsicContentSize: NSSize {
        self.toolbar.intrinsicContentSize
    }
}
