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

class FancyButton : Button {
    
    private var index: Int = 0
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentViewAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        self.contentViewAlignment = .left
    }
    
    var contentViews: [SDKView] = [] {
        didSet {
            self.contentViewIndex = 0
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

            self.setContentView(view)
        }
    }
    
    var contentViewCount: Int {
        return self.contentViews.count
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
                             height: maxSize.height + 10)
        
        return outSize
    }
    
    func defaultLabel(withTitle title: String) -> SDKTextField {
        let label = SDKTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).labelColor
        label.drawsBackground = false
        label.isBordered = false

        return label
    }

}
