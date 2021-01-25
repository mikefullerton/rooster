//
//  ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class FancyButton : SDKButton {
    
    private var index: Int = 0
    
    override init(frame: CGRect) {
        self.contentViews = []
        super.init(frame: frame)
        self.alignment = .left
        self.isBordered = false
        self.setButtonType(.momentaryPushIn)
        self.imagePosition = .imageLeading
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var contentViews: [SDKView] {
        didSet {
            self.contentViewIndex = 0
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var contentViewIndex : Int {
        get {
            return self.index
        }
        set(index) {
            guard index >= 0 && index < self.contentViews.count else {
                return
            }
            
            self.index = index
            
            let view = self.contentViews[index]

            self.setContentView(withView: view)
        }
    }
    
    var contentViewCount: Int {
        return self.contentViews.count
    }
    
    private func setContentView(withView view: SDKView) {
        
        if let imageView = view as? SDKImageView {
            self.title = ""
            self.image = imageView.image
            self.symbolConfiguration = imageView.symbolConfiguration
            self.contentTintColor = imageView.contentTintColor
        } else {
            self.image = nil
        }
        
        if let label = view as? SDKTextField {
            self.title = label.stringValue
            self.contentTintColor = label.textColor
            self.font = label.font
            self.alignment = label.alignment
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var maxAspectRatio: CGFloat = 0
        var maxSize = CGSize.zero
        
        for imageView in self.contentViews {
            
            let size = imageView.intrinsicContentSize
            
            let aspectRatio = size.width / size.height
            
            if maxAspectRatio < aspectRatio {
                maxAspectRatio = aspectRatio
            }
            
            if size.width > maxSize.width {
                maxSize.width = size.width
            }
            
            if size.height > maxSize.height {
                maxSize.height = size.height
            }
        }
    
        let outSize = CGSize(width: maxSize.height * maxAspectRatio,
                             height: maxSize.height)
        
        return outSize
    }
    
    func defaultLabel(withTitle title: String) -> SDKTextField {
        let label = SDKTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).secondaryLabelColor
        label.drawsBackground = false
        label.isBordered = false

        return label
    }

}
