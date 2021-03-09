//
//  ColorPicker.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/25/21.
//

import AppKit
import Foundation

public protocol ColorPickerDelegate: AnyObject {
    func colorPickerGetColor(_ colorPicker: ColorPicker) -> SDKColor?
    func colorPicker(_ colorPicker: ColorPicker, didUpdateColor color: SDKColor)
}

public class ColorPicker: NSObject, Loggable {
    private let colorPicker: NSColorPanel
    public weak var delegate: ColorPickerDelegate?
    public var userInfo: Any?

    private static var currentPicker: ColorPicker? {
        didSet {
            if oldValue != currentPicker {
                oldValue?.detach()
                currentPicker?.attach()
            }
        }
    }

    private func attach() {
        self.colorPicker.isContinuous = true
        self.colorPicker.setTarget(self)
        self.colorPicker.setAction(#selector(colorDidChange(_:)))
        self.colorPicker.makeKeyAndOrderFront(self)
    }

    private func detach() {
        self.colorPicker.setTarget(nil)
        self.colorPicker.setAction(nil)
    }

    public var isCurrentPicker: Bool {
        Self.currentPicker == self
    }

    public init(withDelegate delegate: ColorPickerDelegate?, userInfo: Any? = nil) {
        self.colorPicker = NSColorPanel.shared
        self.delegate = delegate
        self.userInfo = userInfo

        super.init()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(colorChanging(_:)),
                                               name: NSColorPanel.colorDidChangeNotification,
                                               object: self.colorPicker)
    }

    public func show() {
        Self.currentPicker = self
        if let color = self.delegate?.colorPickerGetColor(self) {
            self.colorPicker.color = color
        }
    }

    public func hide() {
        if self.isCurrentPicker {
            self.colorPicker.orderOut(self)
            Self.currentPicker = nil
        }
    }

    @objc func colorChanging(_ notification: Notification) {
        if  self.isCurrentPicker,
            let colorPanel = notification.object as? NSColorPanel {
            self.logger.log("color changing: \(colorPanel.color)")
            self.delegate?.colorPicker(self, didUpdateColor: colorPanel.color)

            self.attach()
        }
    }

    @objc func colorDidChange(_ colorPanel: NSColorPanel) {
        if self.isCurrentPicker {
            self.logger.log("color changed: \(colorPanel.color)")
            self.delegate?.colorPicker(self, didUpdateColor: colorPanel.color)
            self.attach()
        }
    }
}
