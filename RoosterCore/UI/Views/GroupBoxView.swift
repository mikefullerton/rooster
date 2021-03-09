//
//  GroupBoxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class GroupBoxView : SDKView {
 
    public struct Style {
        public enum Side {
            case leading
            case trailing
        }
        
        public static let defaultBoxInsets = SDKEdgeInsets(top: 6, left: 10, bottom: 10, right: 10)
        public static let defaultStackViewInsets = SDKEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)

        public static let defaultStackViewSpacing = SDKOffset.ten
        public static let defaultTitlePosition = CGPoint(x: 30, y: 10)

        public var titleOffset: CGPoint = Style.defaultTitlePosition
        public var titleSide: Side = .leading

        public var boxInsets: SDKEdgeInsets = Style.defaultBoxInsets
        
        public var stackViewInsets: SDKEdgeInsets = Style.defaultStackViewInsets
        public var stackViewSpacing: SDKOffset = Style.defaultStackViewSpacing
        
        public static let `default` = Style()
    }
    
    
    private let outlineView: SimpleStackView
    
    public let style: Style
    
    public init(title: String,
                style: Style = Style.default) {
        
        self.style = style
        self.outlineView = SimpleStackView(direction: .vertical,
                                           insets: style.stackViewInsets,
                                           spacing: style.stackViewSpacing)
        
        super.init(frame: CGRect.zero)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = SDKColor.clear.cgColor
        
        let titleView = self.titleView
        titleView.stringValue = title
        
        self.addTitleView()
        self.addOutlineView()
        
//        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
//        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)

    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addTitleView() {
        let view = self.titleView
        
        self.addSubview(view)
        
        switch self.style.titleSide {
        case .leading:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.style.titleOffset.x),
                view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.style.boxInsets.top),
            ])

        case .trailing:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.style.titleOffset.x),
                view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.style.boxInsets.top),
            ])
        }
        
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func addOutlineView() {
        let view = self.outlineView
        
        view.wantsLayer = true
        view.layer?.cornerRadius = 0
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer?.backgroundColor = SDKColor.clear.cgColor

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.style.boxInsets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.style.boxInsets.right),
            view.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: self.style.boxInsets.top),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.style.boxInsets.bottom)
        ])
    }
    
    public lazy var titleView: SDKTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    open override var intrinsicContentSize: CGSize {
        
        var outSize = CGSize(width: SDKView.noIntrinsicMetric, height: 0)
        
        let textSize = self.titleView.intrinsicContentSize
        let outlineSize = self.outlineView.intrinsicContentSize
        
        outSize.height =    textSize.height +
                            outlineSize.height +
                            self.style.boxInsets.top +
                            self.style.boxInsets.bottom +
                            self.style.titleOffset.y
        
        return outSize
    }
   
    open func setContainedViews(_ views: [SDKView]) {
        self.outlineView.setContainedViews(views)
    }
}

