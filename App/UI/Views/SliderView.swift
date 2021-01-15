//
//  SliderView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import UIKit

class SliderView : UIView {
    
    let insets: UIEdgeInsets
    let spacing: CGFloat = 4
    
    private var minView: UIView?
    private var maxView: UIView?
    
    var fixedMaxViewWidth: CGFloat = 0
    
    var minimumValueView: UIView? {
        get {
            return self.minView
        }
        set(newValue) {
            if newValue != self.minView {
                if self.minView != nil {
                    self.minView!.removeFromSuperview()
                    self.minView = nil
                }
                
                if let view = newValue {
                    view.translatesAutoresizingMaskIntoConstraints = false
                    self.addSubview(view)
                    self.minView = newValue
                
                    self.setNeedsUpdateConstraints()

                    if let button = view as? UIButton {
                        button.addTarget(self, action: #selector(setMinValue(_:)), for: .touchUpInside)
                    }
                }
                
            }
        }
    }
    
    var maximumValueView: UIView? {
        get {
            return self.maxView
        }
        set(newValue) {
            if newValue != self.maxView {
                if self.maxView != nil {
                    self.maxView!.removeFromSuperview()
                    self.maxView = nil
                }
                
                if let view = newValue {
                    view.translatesAutoresizingMaskIntoConstraints = false
                    self.addSubview(view)
                    self.maxView = newValue
                    
                    self.setNeedsUpdateConstraints()
                    
                    if let button = view as? UIButton {
                        button.addTarget(self, action: #selector(setMaxValue(_:)), for: .touchUpInside)
                    }
                }

                
            }
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    init(frame: CGRect,
         insets: UIEdgeInsets = UIEdgeInsets.zero) {
        
        self.insets = insets
        
        super.init(frame: frame)
        
        self.addSubview(self.slider)
        
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        
    }
    
    var minimumValue : Float {
        get { return self.slider.minimumValue }
        set(value) { self.slider.minimumValue = value }
    }
    
    var maximumValue : Float {
        get { return self.slider.maximumValue }
        set(value) { self.slider.maximumValue = value }
    }
    
    var value: Float {
        get { return self.slider.value }
        set(value) { self.slider.value = value }
    }
    
    @objc private func setMinValue(_ sender: UIButton) {
        self.slider.setValue(self.slider.minimumValue, animated: true)
        self.slider.sendActions(for: .valueChanged)
    }

    @objc private func setMaxValue(_ sender: UIButton) {
        self.slider.setValue(self.slider.maximumValue, animated: true)
        self.slider.sendActions(for: .valueChanged)
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        self.slider.addTarget(target, action: action, for: controlEvents)
    }
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.contentVerticalAlignment = .center
        return slider
    }()

    private let weirdVerticalCenteringFudge: CGFloat = 2.0
    
    override var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: UIView.noIntrinsicMetric, height: self.slider.intrinsicContentSize.height + (self.weirdVerticalCenteringFudge*2))
        
        for view in self.subviews {
            let viewSize = view.intrinsicContentSize
            if viewSize.height > outSize.height {
                outSize.height = viewSize.height
            }
        }
        
        outSize.height += self.insets.top + self.insets.bottom
        return outSize
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if let minImage = self.minimumValueView {
            NSLayoutConstraint.activate([
                minImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
                minImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),

                self.slider.leadingAnchor.constraint(equalTo: minImage.trailingAnchor, constant: self.spacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.slider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left)
            ])
        }
        
        if let maxImage = self.maximumValueView {
            
            let width = self.fixedMaxViewWidth != 0 ? self.fixedMaxViewWidth : maxImage.intrinsicContentSize.width
            
            NSLayoutConstraint.activate([
                maxImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
                maxImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                maxImage.widthAnchor.constraint(equalToConstant: width),
                maxImage.heightAnchor.constraint(equalToConstant: maxImage.intrinsicContentSize.height),
                
                self.slider.trailingAnchor.constraint(equalTo: maxImage.leadingAnchor, constant: -self.spacing)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right)
            ])
        }

        NSLayoutConstraint.activate([
            self.slider.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: self.weirdVerticalCenteringFudge),
            self.slider.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])

        self.invalidateIntrinsicContentSize()
    }

}
