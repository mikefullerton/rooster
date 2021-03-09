//
//  SinglePreferenceView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class SinglePreferenceChoiceView: SDKView {
    private let updateCallback: (_ newValue: Bool) -> Void
    private let refreshCallback: () -> Bool
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    public var isEnabled = true {
        didSet { self.checkbox.isEnabled = isEnabled }
    }

    public init(withTitle title: String,
                refresh refreshCallback: @escaping () -> Bool,
                update updateCallback: @escaping (_ newValue: Bool) -> Void) {
        self.refreshCallback = refreshCallback
        self.updateCallback = updateCallback

        super.init(frame: CGRect.zero)

        self.checkbox.title = title

        self.addSubview(self.checkbox)

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.refresh()
        }

        self.refresh()
    }

    override public func updateConstraints() {
        self.addViewsToLayout()
        super.updateConstraints()
    }

    func addViewsToLayout() {
        self.layout.setViews([ self.checkbox ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func checkboxChanged(_ sender: SDKSwitch) {
        self.updateCallback(sender.isOn)
    }

    public lazy var checkbox: SDKSwitch = {
        let view = SDKSwitch(title: "", target: self, action: #selector(checkboxChanged(_:)))
        return view
    }()

    public lazy var layout: VerticalViewLayout = {
        VerticalViewLayout(hostView: self,
                           insets: SDKEdgeInsets.zero,
                           spacing: SDKOffset.zero)
    }()

    public var isOne: Bool {
        get {
            self.checkbox.isOn
        }
        set(value) {
            self.checkbox.isOn = value
        }
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: SDKView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }

    open func refresh() {
        self.checkbox.isOn = self.refreshCallback()
    }
}
