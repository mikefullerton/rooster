//
//  SDKImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
import Cocoa

class SDKCustomButtonOld: ContentAwareView, TrackingButtonDelegate, CALayerDelegate {
    
    private(set) var imageView: NSImageView?
    private(set) var textField: NSTextField?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.sdkLayer.delegate = self
        self.canDrawSubviewsIntoLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layerContentsPlacement = .center
        self.addButton()

        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)

        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    public convenience init(target: AnyObject?,
                            action: Selector?,
                            toolTip: String?) {

        self.init(frame: CGRect.zero)
        
        self.target = target
        self.action = action
        self.toolTip = toolTip
    }
   
    public convenience init(title: String,
                            image: SDKImage,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String?) {

        self.init(target:target, action:action, toolTip: toolTip)
        
        // TODO: adjust contraints for this
        
        self.title = title
        self.image = image
        self.setConstraints()
    }
    
    public convenience init(image: NSImage,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(target:target, action:action, toolTip: toolTip)
        self.image = image
        self.setConstraints()
    }

     public convenience init(imageName: String,
                             target: AnyObject?,
                             action: Selector?,
                             toolTip: String) {

        self.init(target:target, action:action, toolTip: toolTip)
        self.image = NSImage(named: imageName)
        self.setConstraints()
    }
    
    public convenience init(systemImageName: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(target:target, action:action, toolTip: toolTip)
        self.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        self.image = SDKImage(systemSymbolName: systemImageName, accessibilityDescription: self.toolTip)
        
        self.setConstraints()
    }
    
    public convenience init(title: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        self.init(target:target, action:action, toolTip: toolTip)
        self.title = title
        self.setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(_ layer: CALayer) {
        let frame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.frame = frame
    }
    
    func setContraints(forView view: NSView, forAlignment alignment: NSTextAlignment) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.deactivate(view.constraints)
        
        var constraints: [NSLayoutConstraint] = []
        
        switch(alignment) {
        case .left:
            constraints = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ]

        case .right:
            constraints = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ]

        case .center:
            constraints = [
                view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ]
        case .justified:
            break
        case .natural:
            break
        @unknown default:
            break
        }
        
        constraints.forEach { $0.priority = .required }
        
        NSLayoutConstraint.activate(constraints)
        
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setSizeContraints(forImageView view: NSImageView) {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
        ])
    }
    
    func setSizeConstraints(forTextField view: NSTextField) {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
        ])
    }
    
    func setConstraints() {
        
        if let view = self.imageView {
            self.setContraints(forView: view, forAlignment: self.alignment)
            self.setSizeContraints(forImageView: view)
        }
        
        if let view = self.textField {
            self.setContraints(forView: view, forAlignment: self.alignment)
            self.setSizeConstraints(forTextField: view)
        }
    }
    
    func addImageView() {
        if self.imageView != nil {
            return
        }
        
        let view = NSImageView()
        self.addSubview(view, positioned: .below, relativeTo: self.button)
        self.imageView = view
        self.needsUpdateConstraints = true
    }
    
    func addTextField() {
        
        if self.textField != nil {
            return
        }
        
        let view = NSTextField()
        view.isSelectable = false
        view.alignment = .center
        view.backgroundColor = SDKColor.clear
        view.textColor = Theme(for: self).labelColor
        view.isBordered = false
        view.drawsBackground = false
        view.isEditable = false
        self.addSubview(view, positioned: .below, relativeTo: self.button)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.needsUpdateConstraints = true
        
        self.textField = view
    }
    
    private lazy var button: TrackingButton = {
        let button = TrackingButton()
        button.isTransparent = true
        button.delegate = self
        return button
    }()
    
    func addButton() {
        let view = self.button
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
            
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func trackingButton(_ buttton: TrackingButton, didHighlight isHighlighted: Bool) {
        self.updateHighlightState()
    }
    
    private func updateHighlightState() {
        if self.button.isHighlighted {
            self.imageView?.alphaValue = 0.6
            self.textField?.alphaValue = 0.6
        } else {
            self.imageView?.alphaValue = 1.0
            self.textField?.alphaValue = 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        
        if let imageView = self.imageView,
           let image = imageView.image {
            return image.size
            
            // this doesn't work correctly for height
//            return imageView.intrinsicContentSize
        }
        
        if let textField = self.textField {
            return textField.intrinsicContentSize
        }
        
        return CGSize.zero
    }
    
    /// MARK: button shims
    
    var isEnabled: Bool {
        get {
            return self.button.isEnabled
        }
        set(enabled) {
            self.button.isEnabled = enabled
            
            if enabled {
                self.imageView?.alphaValue = 1.0
                self.textField?.alphaValue = 1.0
            } else {
                self.imageView?.alphaValue = 0.5
                self.textField?.alphaValue = 0.5
            }
        }
    }
    
    var target: AnyObject? {
        get {
            return self.button.target
        }
        set(target) {
            self.button.target = target
        }
    }
    
    var action: Selector? {
        get {
            return self.button.action
        }
        set(action) {
            self.button.action = action
        }
    }

    var image: SDKImage? {
        get {
            return self.imageView?.image
        }
        set(image) {
            if image != nil {
                self.addImageView()
            
                if let config = self.symbolConfiguration {
                    self.imageView?.image = image!.withSymbolConfiguration(config)
                } else {
                    self.imageView?.image = image
                }
                
                self.imageView?.invalidateIntrinsicContentSize()
            }
        }
    }
    
    var symbolConfiguration: NSImage.SymbolConfiguration? {
        didSet {
            if let config = self.symbolConfiguration {
                self.addImageView()
                if let image = self.imageView?.image {
                    self.imageView?.image = image.withSymbolConfiguration(config)
                }
                self.imageView?.invalidateIntrinsicContentSize()
            }
        }
    }
    
    var title: String {
        get {
            return self.textField?.stringValue ?? ""
        }
        set(title) {
            if title.count > 0 {
                self.addTextField()
            }
            
            self.textField?.stringValue = title
            self.setConstraints()
        }
    }

    var font: NSFont? {
        get {
            return self.textField?.font
        }
        set(font) {
            self.addTextField()
            self.textField?.font = font
            self.textField?.invalidateIntrinsicContentSize()
        }
    }
    
    var contentTintColor: NSColor? {
        didSet {
            self.textField?.textColor = self.contentTintColor
            self.imageView?.contentTintColor = self.contentTintColor
        }
    }
    
    var alignment: NSTextAlignment = .center {
        didSet {
            
            switch(self.alignment) {
            case .left:
            self.imageView?.imageAlignment = .alignLeft
            
            case .right:
            self.imageView?.imageAlignment = .alignRight
            
            case .center:
            self.imageView?.imageAlignment = .alignCenter
            
            case .justified:
                break
                
            case .natural:
                break
            
                
            @unknown default:
                self.imageView?.imageAlignment = .alignCenter
            }
            
            self.textField?.alignment = self.alignment
            self.setConstraints()
        }
    }
    
    
}

