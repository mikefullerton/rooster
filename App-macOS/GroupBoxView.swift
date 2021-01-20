//
//  GroupBoxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import Cocoa

class GroupBoxView : NSView {
 
    let layoutInsets: NSEdgeInsets
    let insets = NSEdgeInsets.zero
    let spacing: CGFloat = 0
    
    static let defaultInsets = NSEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    init(frame: CGRect,
         title: String,
         insets: NSEdgeInsets = GroupBoxView.defaultInsets) {
        
        self.layoutInsets = insets
        
        super.init(frame: frame)
        
        self.backgroundColor = NSColor.clear
        let titleView = self.titleView
        titleView.text = title
        
        self.addSubview(self.titleView)
        NSLayoutConstraint.activate([
            self.titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6 - 10),
            self.titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.insets.top),
        ])

        self.addSubview(self.outlineView)
        NSLayoutConstraint.activate([
            self.outlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.insets.left),
            self.outlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.insets.right),
            self.outlineView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: self.spacing),
            self.outlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.insets.bottom)
        ])

        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)

    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, title: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy private var outlineView = OutlineView(frame:CGRect.zero, insets: self.layoutInsets)
    
    lazy private var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return titleView
    }()

    override var intrinsicContentSize: CGSize {
        
        var outSize = CGSize(width: NSView.noIntrinsicMetric, height: 0)
        
        let textSize = self.titleView.intrinsicContentSize
        let outlineSize = self.outlineView.intrinsicContentSize
        
        outSize.height += textSize.height + self.insets.top
        outSize.height += self.spacing
        outSize.height += outlineSize.height + self.insets.bottom

        return outSize
    }
   
    func setContainedViews(_ views: [NSView]) {
        for view in views {
            self.outlineView.addSubview(view)
        }
        self.outlineView.layout.setViews(views)
    }
}

class OutlineView : NSView {

    let insets: NSEdgeInsets
    
    init(frame: CGRect, insets: NSEdgeInsets) {
        self.insets = insets
        super.init(frame: frame)
        
        self.layer.cornerRadius = 0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Theme(for: self).borderColor.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = Theme(for: self).groupBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }

    lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets:  self.insets,
                                  spacing: UIOffset(horizontal: 10, vertical: 10))
    }()
}
