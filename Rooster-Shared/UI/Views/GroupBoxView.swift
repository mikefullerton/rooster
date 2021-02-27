//
//  GroupBoxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class GroupBoxView : SDKView {
 
    let insets: SDKEdgeInsets
    let spacing: CGFloat
    
    private let outlineView: SimpleStackView
    
    static let defaultInsets = SDKEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    static let defaultSpacing: CGFloat = 6
    static let defaultGroupBoxInsets = SDKEdgeInsets.twenty
    static let defaultGroupBoxSpacing = SDKOffset.ten
    
    init(frame: CGRect,
         title: String,
         groupBoxInsets: SDKEdgeInsets,
         groupBoxSpacing: SDKOffset,
         insets: SDKEdgeInsets = GroupBoxView.defaultInsets,
         spacing: CGFloat = GroupBoxView.defaultSpacing) {
        
        self.insets = insets
        self.spacing = spacing
        self.outlineView = SimpleStackView(frame: CGRect.zero,
                                           direction: .vertical,
                                           insets: groupBoxInsets,
                                           spacing: groupBoxSpacing)
        
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = SDKColor.clear.cgColor
        
        let titleView = self.titleView
        titleView.stringValue = title
        
        self.addTitleView()
        self.addOutlineView()
        
        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitleView() {
        let view = self.titleView
        
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6 - 10),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.insets.top),
        ])
        view.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
        view.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
    }

    func addOutlineView() {
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
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
            view.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: self.spacing),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.insets.bottom)
        ])
    }
    
    lazy private var titleView: SDKTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).labelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    override var intrinsicContentSize: CGSize {
        
        var outSize = CGSize(width: SDKView.noIntrinsicMetric, height: 0)
        
        let textSize = self.titleView.intrinsicContentSize
        let outlineSize = self.outlineView.intrinsicContentSize
        
        outSize.height += textSize.height + self.insets.top
        outSize.height += self.spacing
        outSize.height += outlineSize.height + self.insets.bottom

        return outSize
    }
   
    func setContainedViews(_ views: [SDKView]) {
        self.outlineView.setContainedViews(views)
    }
}

