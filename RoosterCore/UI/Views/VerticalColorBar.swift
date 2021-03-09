//
//  CalendarColorBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class VerticalColorBar : SDKView {
    public static let defaultInsets = SDKEdgeInsets.ten
    public static let defaultWidth: CGFloat = 6

    public let insets: SDKEdgeInsets
    public let barWidth: CGFloat
    public let roundedCorners: Bool

    public override init(frame: CGRect) {
        self.insets = VerticalColorBar.defaultInsets
        self.barWidth = VerticalColorBar.defaultWidth
        self.roundedCorners = true
        
        super.init(frame: frame)
        
        self.sdkBackgroundColor = SDKColor.clear
        self.addColorBar()
    }
    
    public init(insets: SDKEdgeInsets,
                barWidth: CGFloat,
                roundedCorners: Bool) {

        self.insets = insets
        self.barWidth = barWidth
        self.roundedCorners = roundedCorners
        
        super.init(frame: CGRect.zero)

        self.sdkBackgroundColor = SDKColor.clear
        self.addColorBar()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var colorBarView: SDKView = {
        let view = SDKView()
        
        if self.roundedCorners {
            view.sdkLayer.cornerRadius = self.barWidth / 2.0
        }
        
        return view
    }()
    
    private func addColorBar() {
    
        let view = self.colorBarView
        
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: self.barWidth),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.insets.top),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.insets.bottom),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    public var color: SDKColor? {
        get {
            return self.colorBarView.sdkBackgroundColor
        }
        set(color) {
            self.colorBarView.sdkBackgroundColor = color
        }
    }
    
    public override var intrinsicContentSize: NSSize {
        return CGSize(width: self.insets.left + self.insets.right + self.barWidth,
                      height: SDKView.noIntrinsicMetric)
    }
}
