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

open class FancyButton : Button {
    
    public var animateableContent: AnimatableButtonContentView {
        return self.contentView as! AnimatableButtonContentView
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        self.addContentView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addContentView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        self.addContentView()
    }
    
    private func addContentView() {
        self.contentViewAlignment = .left
        self.setContentView(AnimatableButtonContentView())
    }
    

    
}

open class AnimatableButtonContentView : AnimateableView, AbstractButtonContentView {
    private var index: Int = 0
    
    private weak var button: AbstractButton?

    public func wasAdded(toButton button: AbstractButton) {
        self.button = button
    }
    
    public func updateForPosition(_ position: SDKView.Position, inButton button: AbstractButton) {
        if let currentView = self.currentView {
            self.updateCurrentViewConstraints(currentView)
        }
    }
    
    public func updateForDisplay(inButton button: AbstractButton) {
        self.contentViews.forEach {
            if let buttonContent = $0 as? AbstractButtonContentView {
                buttonContent.updateForDisplay(inButton: button)
            }
        }
    }
    
    public func updateConstraints(forLayoutInButton button: AbstractButton) {
        
    }
    
    public var contentViews: [SDKView] = [] {
        didSet {
            self.viewIndex = self.contentViews.count > 0 ? 0 : -1
        }
    }
    
    public var viewIndex : Int {
        get {
            return self.index
        }
        set(index) {
            guard index >= 0 && index < self.contentViews.count else {
                return
            }
            
            self.index = index
            self.currentView = self.contentViews[index]
        }
    }
    
    public var maxViewIndex: Int {
        return self.contentViews.count - 1
    }
    
    public private(set) var currentView: SDKView? {
        didSet {
            if oldValue != self.currentView {
                
                if let previous = oldValue {
                    previous.removeFromSuperview()
                }
                
                if let current = self.currentView {
                    self.addSubview(current)
                    self.updateCurrentViewConstraints(current)
                }
            }
        }
    }
    
    private func updateCurrentViewConstraints(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if let button = self.button {
            self.setPositionalContraints(forSubview: view, alignment: button.contentViewAlignment)
        }
    }
    
    public var viewCount: Int {
        return self.contentViews.count
    }

    public override var intrinsicContentSize: CGSize {
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
    
    public func setNextAnimatableView() {
        var index = self.viewIndex + 1
        if index > self.maxViewIndex {
            index = 0
        }

        self.viewIndex = index
    }
    
}
