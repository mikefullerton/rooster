//
//  TipView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

struct Tip {
    let image: SDKImage?
    let imageTintColor: SDKColor?
    let title: String
    let action: (() -> Void)?
}

class TipView : SDKView {
    
    let tip: Tip
    
    init(frame: CGRect,
         tip: Tip) {
        self.tip = tip
        super.init(frame: frame)
        
        self.addSubview(self.tipImage)
        self.addSubview(self.textField)
        
        self.layout.setViews([
            self.tipImage,
            self.textField
        ])
 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textField: SDKTextField = {
        let titleView = SDKTextField()
        titleView.stringValue = self.tip.title
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false

        return titleView
    }()
    
    let imageSize: CGFloat = 14.0
    
    lazy var tipImage: SDKImageView = {
        guard let image = self.tip.image else {
            return SDKImageView()
        }
        
        let view = SDKImageView(image: image)
        if self.tip.imageTintColor != nil {
            view.contentTintColor = self.tip.imageTintColor! // SDKColor.systemBlue
        }
        return view
    }()
        
    override var intrinsicContentSize: CGSize {
        return CGSize(width: SDKView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }
    
    lazy var layout: HorizontalViewLayout = {
        return HorizontalViewLayout(hostView: self,
                                    insets: SDKEdgeInsets(top: 2, left: 20, bottom: 10, right: 0),
                                    spacing: SDKOffset(horizontal: 6, vertical: 0),
                                    alignment: .left)
        
    }()
}
