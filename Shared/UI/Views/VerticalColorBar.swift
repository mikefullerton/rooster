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

class VerticalColorBar : SDKView {
    static let defaultInsets = SDKEdgeInsets.ten
    static let defaultWidth: CGFloat = 6

    let insets: SDKEdgeInsets
    let barWidth: CGFloat
    let roundedCorners: Bool

    override init(frame: CGRect) {
        self.insets = VerticalColorBar.defaultInsets
        self.barWidth = VerticalColorBar.defaultWidth
        self.roundedCorners = true
        
        super.init(frame: frame)
        
        self.sdkBackgroundColor = SDKColor.clear
        self.addColorBar()
    }
    
    init(insets: SDKEdgeInsets,
         barWidth: CGFloat,
         roundedCorners: Bool) {

        self.insets = insets
        self.barWidth = barWidth
        self.roundedCorners = roundedCorners
        
        super.init(frame: CGRect.zero)

        self.sdkBackgroundColor = SDKColor.clear
        self.addColorBar()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorBarView: SDKView = {
        let view = SDKView()
        
        if self.roundedCorners {
            view.sdkLayer.cornerRadius = self.barWidth / 2.0
        }
        
        return view
    } ()
    
    func addColorBar() {
    
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
    
    var color: SDKColor? {
        get {
            return self.colorBarView.sdkBackgroundColor
        }
        set(color) {
            self.colorBarView.sdkBackgroundColor = color
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return CGSize(width: self.insets.left + self.insets.right + self.barWidth,
                      height: SDKView.noIntrinsicMetric)
    }
}
