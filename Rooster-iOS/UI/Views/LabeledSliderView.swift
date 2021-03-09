//
//  LabeledSliderView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import UIKit

class LabeledSliderView: UIView {
    let labelFixedWidth: CGFloat
    let sliderRightInset: CGFloat

    init(frame: CGRect,
         title: String,
         fixedLabelWidth: CGFloat,
         sliderRightInset: CGFloat) {
        self.labelFixedWidth = fixedLabelWidth
        self.sliderRightInset = sliderRightInset

        super.init(frame: frame)

        self.addSubview(self.label)
        self.addSubview(self.slider)
        self.slider.fixedMaxViewWidth = sliderRightInset

        self.label.text = title

        self.setNeedsUpdateConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var slider: SliderView = {
        let sliderView = SliderView()
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        return sliderView
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()

    override var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: UIView.noIntrinsicMetric, height: 0)
        outSize.height = CGFloat.maximum(self.slider.intrinsicContentSize.height, self.label.intrinsicContentSize.height)
        return outSize
    }

    override func updateConstraints() {
        super.updateConstraints()

        NSLayoutConstraint.activate([
            self.label.lastBaselineAnchor.constraint(equalTo: self.centerYAnchor, constant: 3),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            self.slider.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.slider.leadingAnchor.constraint(equalTo: self.label.trailingAnchor, constant: 10),
            self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        if self.labelFixedWidth != 0 {
            NSLayoutConstraint.activate([
                self.label.widthAnchor.constraint(equalToConstant: self.labelFixedWidth)
            ])
        }

        self.invalidateIntrinsicContentSize()
    }
}
