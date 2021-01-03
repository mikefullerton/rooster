//
//  GroupBoxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class GroupBoxView : UIView {
 
    let layoutInsets: UIEdgeInsets
    let insets = UIEdgeInsets.zero
    let spacing: CGFloat = 0
    
    static let defaultInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    init(frame: CGRect,
         title: String,
         insets: UIEdgeInsets = GroupBoxView.defaultInsets) {
        
        self.layoutInsets = insets
        
        super.init(frame: frame)
        
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
    
    lazy private var titleView: UITextField = {
        let titleView = UITextField()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.sizeToFit()
        
        return titleView
    }()

    override var intrinsicContentSize: CGSize {
        
        var outSize = CGSize(width: UIView.noIntrinsicMetric, height: 0)
        
        let textSize = self.titleView.intrinsicContentSize
        let outlineSize = self.outlineView.intrinsicContentSize
        
        outSize.height += textSize.height + self.insets.top
        outSize.height += self.spacing
        outSize.height += outlineSize.height + self.insets.bottom

        return outSize
    }
   
    func addContainedView(_ view: UIView) {
        self.outlineView.addSubview(view)
        self.outlineView.layout.addView(view)
        
        self.invalidateIntrinsicContentSize()
    }
}

class OutlineView : UIView {

    let insets: UIEdgeInsets
    
    init(frame: CGRect, insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: frame)
        
        self.layer.cornerRadius = 0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.separator.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }

    lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets:  self.insets,
                                  spacing: UIOffset(horizontal: 10, vertical: 10))
    }()

    override func updateConstraints() {
        super.updateConstraints()

        self.layout.updateConstraints()
        self.invalidateIntrinsicContentSize()
    }
    
}
