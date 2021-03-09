//
//  PreferenceView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/22/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class PreferenceView<T>: SDKView {
    public var setter: (_ view: T) -> Void
    public var updater: (_ view: T) -> Void
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    public var isEnabled = true

    public init(updater: @escaping (_ view: T) -> Void,
                setter: @escaping (_ view: T) -> Void) {
        self.updater = updater
        self.setter = setter

        super.init(frame: CGRect.zero)

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.refresh()
        }

        self.refresh()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("unavailable")
    }

    open func refresh() {
        guard let view = self as? T else {
            return
        }

        self.updater(view)
    }
}
