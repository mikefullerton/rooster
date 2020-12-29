//
//  GroupBoxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class GroupBoxView : UIView {
 
    let title: String
    
    let insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
    
    init(frame: CGRect, title: String) {
        self.title = title
        super.init(frame: frame)
        
        let _ = self.outLineView
        self.titleView.text = title
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, title: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let inset: CGFloat = 6

    lazy var outLineView : UIView = {
        let outlineView = UIView()
        outlineView.layer.cornerRadius = 0
        outlineView.layer.borderWidth = 1.0
        outlineView.layer.borderColor = UIColor.separator.cgColor
        
        self.addSubview(outlineView)
        
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            outlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            outlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            outlineView.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: 0),
            outlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)
        ])

        return outlineView
    }()
    
    lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.text = self.title
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .right
        
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.sizeToFit()
        
        NSLayoutConstraint.activate([
            titleView.widthAnchor.constraint(equalToConstant: titleView.frame.size.width),
            titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset - 10),
            titleView.topAnchor.constraint(equalTo: self.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: titleView.frame.size.height)
        ])

        return titleView
    }()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.layout.size.height + self.insets.top + self.insets.bottom
        return outSize
    }
    
    lazy var layout: ViewLayout = {
        return VerticalViewLayout(hostView: self.outLineView,
                                  insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                                  spacing: UIOffset(horizontal: 10, vertical: 10))
    }()
}
