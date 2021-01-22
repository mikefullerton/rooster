//
//  TopBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

import Cocoa


class TopBar : BlurView {
    
    var preferredHeight:CGFloat {
        return 40.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.setContentHuggingPriority(., for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.backgroundColor = NSColor.clear
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.isBordered = false
        titleView.drawsBackground = false
        titleView.isEditable = false
        titleView.alignment = .center
        return titleView
    }()
        
    func addTitleView(withText text: String) {
        let titleView = self.titleView
        titleView.stringValue = text
        
        self.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    func addToView(_ view: NSView) {
        
        view.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.preferredHeight),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: self.preferredHeight)
    }
}
