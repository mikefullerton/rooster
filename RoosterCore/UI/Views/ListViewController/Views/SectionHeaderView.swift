//
//  SectionHeaderView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class SectionHeaderView : BlurView, ListViewAdornmentView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTitleView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.systemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    public func addTitleView() {
        let titleView = self.titleView
       
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    open func viewWillAppear(withContent contents: ListViewSectionAdornmentProtocol) {
        if contents.title != nil {
            self.titleView.stringValue = contents.title!
        } else {
            self.titleView.stringValue = ""
        }
    }
    
    open class func preferredSize(forContent content: Any?) -> CGSize {
        return CGSize(width: -1, height: 30.0)
    }

    
}

