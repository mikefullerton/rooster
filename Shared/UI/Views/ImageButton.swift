//
//  ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import AppKit

class ImageButton: Button {
    
    var imageView: SDKImageView {
        return self.contentView as! SDKImageView
    }

    var symbolConfiguration: NSImage.SymbolConfiguration?
    
    var image: NSImage? {
        get {
            return self.imageView.image
        }
        set(image) {
            if image != self.imageView.image {
                self.imageView.image = image
//                self.imageView.isEditable = false
//                self.imageView.imageAlignment = .alignCenter
//                self.imageView.imageScaling = .scaleProportionallyUpOrDown
//                if self.symbolConfiguration != nil {
//                    self.imageView.symbolConfiguration = self.symbolConfiguration!
//                }
//                self.imageView.sizeToFit()
                self.invalidateIntrinsicContentSize()
                
                self.mouseStateDidChange()
            }
        }
    }

    convenience init() {
        self.init(withImage: nil)
    }
    
    init(withImage image: NSImage?, symbolConfiguration: NSImage.SymbolConfiguration? = nil) {

        super.init(withContentView: NSImageView())
        
//        self.imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        self.symbolConfiguration = symbolConfiguration
        self.image = image
        
        
    }
    
    convenience init(withSystemImageName name: String,
                     symbolConfiguration: NSImage.SymbolConfiguration? = nil) {
        
        var image = NSImage(systemSymbolName: name, accessibilityDescription: name)

        if image != nil && symbolConfiguration != nil {
            image = image!.withSymbolConfiguration(symbolConfiguration!)
        }
        
        self.init(withImage: image)
    }

    convenience init(imageName name: String) {
        let image = NSImage(named: name)
        self.init(withImage: image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

}
