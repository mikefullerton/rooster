//
//  Button+ConvenienceInit.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/17/21.
//

import Foundation
#if os(macOS)
import Cocoa
import AppKit

#else
import UIKit
#endif

extension Button {
    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public convenience init(image: NSImage,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(image: NSImage,
                            callback: @escaping Callback) {
        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            symbolConfiguration: NSImage.SymbolConfiguration,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: symbolConfiguration)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: nil)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            symbolConfiguration: NSImage.SymbolConfiguration,
                            callback: @escaping Callback) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: symbolConfiguration)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            callback: @escaping Callback) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: nil)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(imageName: String,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        let image = NSImage(named: imageName)

        assert(image != nil, "image for name \(imageName) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(imageName: String,
                            callback: @escaping Callback) {
        let image = NSImage(named: imageName)

        assert(image != nil, "image for name \(imageName) is nil")

        self.init(title: nil,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(title: String,
                            image: NSImage,
                            imagePosition: ConstraintDescriptor = .center,
                            spacing: CGFloat = 0,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        self.init(title: title,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: imagePosition,
                  textPosition: .center,
                  spacing: spacing,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(title: String,
                            image: NSImage,
                            imagePosition: ConstraintDescriptor,
                            spacing: CGFloat,
                            callback: @escaping Callback) {
        self.init(title: title,
                  attributedTitle: nil,
                  image: image,
                  imagePosition: imagePosition,
                  textPosition: .center,
                  spacing: spacing,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(title: String,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        self.init(title: title,
                  attributedTitle: nil,
                  image: nil,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(title: String,
                            callback: @escaping Callback) {
        self.init(title: title,
                  attributedTitle: nil,
                  image: nil,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }

    public convenience init(target: AnyObject,
                            action: Selector) {
        self.init(title: nil,
                  attributedTitle: nil,
                  image: nil,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: target,
                  action: action,
                  callback: nil)
    }

    public convenience init(callback: @escaping Callback) {
        self.init(title: nil,
                  attributedTitle: nil,
                  image: nil,
                  imagePosition: .center,
                  textPosition: .center,
                  spacing: 0,
                  target: nil,
                  action: nil,
                  callback: callback)
    }
}
