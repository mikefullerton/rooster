//
//  ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import AppKit

open class ImageButton: Button {
    
    public var imageView: SDKImageView {
        return self.contentView as! SDKImageView
    }

    public var symbolConfiguration: NSImage.SymbolConfiguration?
    
    public var image: NSImage? {
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
                
                self.updateContents()
            }
        }
    }

    public convenience init() {
        self.init(withImage: nil)
    }
    
    public init(withImage image: NSImage?, symbolConfiguration: NSImage.SymbolConfiguration? = nil) {

        super.init(withContentView: SizedImageView())
        
//        self.imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        self.symbolConfiguration = symbolConfiguration
        self.image = image
        
        
    }
    
    public convenience init(withSystemImageName name: String,
                     symbolConfiguration: NSImage.SymbolConfiguration? = nil) {
        
        var image = NSImage(systemSymbolName: name, accessibilityDescription: name)

        if image != nil && symbolConfiguration != nil {
            image = image!.withSymbolConfiguration(symbolConfiguration!)
        }
        
        self.init(withImage: image)
    }

    public convenience init(imageName name: String) {
        let image = NSImage(named: name)
        self.init(withImage: image)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

}
