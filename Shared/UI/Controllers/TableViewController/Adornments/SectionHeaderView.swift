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

class SectionHeaderView : BlurView, TableViewAdornmentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTitleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.systemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    func addTitleView() {
        let titleView = self.titleView
       
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func viewWillAppear(withContent contents: TableViewSectionAdornmentProtocol) {
        if contents.title != nil {
            self.titleView.stringValue = contents.title!
        } else {
            self.titleView.stringValue = ""
        }
    }
    
    static var preferredHeight: CGFloat {
        return 30.0
    }
    
}

