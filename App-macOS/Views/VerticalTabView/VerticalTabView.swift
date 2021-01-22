//
//  VerticalTabView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import Cocoa

class VerticalTabView : NSView {
    
    private var buttonBar: NSView?
    
    let buttonBarInsets = NSEdgeInsets.ten
    
    lazy var contentContainerView : NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = Theme(for: view).preferencesContentViewColor.cgColor
        return view
    }()
    
    private var contentView: NSView?

    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addButtonBarView(_ view: NSView) {
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
       
        let size = CGSize(width: 150, height: 0)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.buttonBarInsets.left),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.buttonBarInsets.top),
            view.widthAnchor.constraint(equalToConstant:size.width + self.buttonBarInsets.right),
            
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])
        
        self.buttonBar = view
        
        self.addContentContainerView()
        
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 800, height: 800)

//        return CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
    
    func addContentContainerView() {
        let view = self.contentContainerView
        
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = Theme(for: self).borderColor.cgColor
        view.layer?.cornerRadius = 6.0
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.buttonBar!.trailingAnchor, constant: self.buttonBarInsets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.buttonBarInsets.right),
            
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.buttonBarInsets.top),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.buttonBarInsets.bottom)
        ])
    }
    
    func setContentView(_ view: NSView) {
        
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
            self.contentView = nil
        }
        
        self.contentContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer?.backgroundColor = NSColor.clear.cgColor
        view.frame = self.contentContainerView.bounds
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.contentContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentContainerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.contentContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentContainerView.bottomAnchor)
        ])
       
        self.contentView = view
    }
}
