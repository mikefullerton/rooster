//
//  SliderView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation

#if os(macOS)
import Cocoa
import AppKit
#else
import UIKit
#endif

open class SliderView: SDKView {
    private(set) var insets = SDKEdgeInsets.zero

    public let spacing: CGFloat = 8
    public let minSliderWidth: CGFloat = 100.0

    private var target: Any?
    private var action: Selector?

    private(set) var minValueView: SDKView?
    private(set) var maxValueView: SDKView?

    private(set) var minValueViewFixedWidth: CGFloat = 0
    private(set) var maxValueViewFixedWidth: CGFloat = 0

    public var minimumValue: Double {
        get { self.slider.minValue }
        set(value) { self.slider.minValue = value }
    }

    public var maximumValue: Double {
        get { self.slider.maxValue }
        set(value) { self.slider.maxValue = value }
    }

    public var value: Double {
        get { self.slider.doubleValue }
        set(value) { self.slider.doubleValue = value }
    }

    @objc open func setMinValue(_ sender: Any) {
        self.value = self.minimumValue
        self.slider.sendAction(self.slider.action, to: self.slider.target)
    }

    @objc open func setMaxValue(_ sender: Any) {
        self.value = self.maximumValue
        self.slider.sendAction(self.slider.action, to: self.slider.target)
    }

    public var tickMarkCount: Int {
        get { self.slider.numberOfTickMarks }
        set(count) {
            self.slider.numberOfTickMarks = count
        }
    }

    public var tickMarkPosition: NSSlider.TickMarkPosition {
        get { self.slider.tickMarkPosition }
        set(position) {
            self.slider.tickMarkPosition = position
        }
    }

    public func tickMarkValue(at index: Int) -> Double {
        self.slider.tickMarkValue(at: index)
    }

    public var allowsTickMarkValuesOnly: Bool {
        get { self.slider.allowsTickMarkValuesOnly }
        set(value) {
            self.slider.allowsTickMarkValuesOnly = value
        }
    }

    open func setViews(minValueView: SDKView?,
                       maxValueView: SDKView?,
                       insets: SDKEdgeInsets = SDKEdgeInsets.zero,
                       minValueViewFixedWidth: CGFloat = 0,
                       maxValueViewFixedWidth: CGFloat = 0) {
        self.minValueView = minValueView
        self.maxValueView = maxValueView
        self.minValueViewFixedWidth = minValueViewFixedWidth
        self.maxValueViewFixedWidth = maxValueViewFixedWidth
        self.insets = insets

        self.addMinValueView()
        self.addMaxValueView()
        self.addSlider()
    }

    open func setTarget(_ target: AnyObject?, action: Selector) {
        self.slider.target = target
        self.slider.action = action
    }

    public lazy var slider: SDKSlider = {
        let slider = SDKSlider()
        slider.minValue = 0
        slider.maxValue = 1.0
        slider.alignment = .center
        slider.isVertical = false
        return slider
    }()

    private func addSlider() {
        self.slider.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.slider)

        NSLayoutConstraint.activate([
            self.slider.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.slider.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minSliderWidth)
        ])

        if let view = self.minValueView {
            NSLayoutConstraint.activate([
                self.slider.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: self.spacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.slider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left)
            ])
        }

        if let view = self.maxValueView {
            NSLayoutConstraint.activate([
                self.slider.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.spacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right)
            ])
        }
    }

    private func addMinValueView() {
        if let view = self.minValueView {
            view.translatesAutoresizingMaskIntoConstraints = false

            self.addSubview(view)

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

            if self.minValueViewFixedWidth > 0 {
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: self.minValueViewFixedWidth)
                ])
            }
        }
    }

    private func addMaxValueView() {
        if let view = self.maxValueView {
            view.translatesAutoresizingMaskIntoConstraints = false

            self.addSubview(view)

            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

            if self.maxValueViewFixedWidth > 0 {
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: self.maxValueViewFixedWidth)
                ])
            }
        }
    }

    override open var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        outSize.height = self.slider.intrinsicContentSize.height

        for view in self.subviews {
            let viewSize = view.intrinsicContentSize
            if viewSize.height > outSize.height {
                outSize.height = viewSize.height
            }
        }
        outSize.height += self.insets.top + self.insets.bottom

        outSize.width = self.insets.left + self.insets.right + self.minSliderWidth

        if let view = self.minValueView {
            outSize.width += self.spacing +
                             self.minValueViewFixedWidth > 0 ? self.minValueViewFixedWidth : view.intrinsicContentSize.width
        }

        if let view = self.maxValueView {
            outSize.width += self.spacing +
                             self.maxValueViewFixedWidth > 0 ? self.maxValueViewFixedWidth : view.intrinsicContentSize.width
        }

        return outSize
    }
}
