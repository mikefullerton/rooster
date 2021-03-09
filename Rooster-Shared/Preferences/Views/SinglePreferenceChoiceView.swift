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

open class SinglePreferenceChoiceView: PreferenceView<SinglePreferenceChoiceView> {
    override public var isEnabled: Bool {
        didSet { self.checkbox.isEnabled = isEnabled }
    }

    public init(withTitle title: String,
                updater: @escaping (_ view: SinglePreferenceChoiceView) -> Void,
                setter: @escaping (_ view: SinglePreferenceChoiceView) -> Void) {
        super.init(updater: updater, setter: setter)

        self.checkbox.title = title
        self.addSubview(self.checkbox)
    }

    override public func updateConstraints() {
        self.addViewsToLayout()
        super.updateConstraints()
    }

    func addViewsToLayout() {
        self.layout.setViews([ self.checkbox ])
    }

    @objc func checkboxChanged(_ sender: SDKSwitch) {
        self.setter(self)
    }

    public lazy var checkbox: SDKSwitch = {
        let view = SDKSwitch(target: self, action: #selector(checkboxChanged(_:)))
        return view
    }()

    public lazy var layout: VerticalViewLayout = {
        VerticalViewLayout(hostView: self,
                           insets: SDKEdgeInsets.zero,
                           spacing: SDKOffset.zero)
    }()

    public var isOn: Bool {
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
}
