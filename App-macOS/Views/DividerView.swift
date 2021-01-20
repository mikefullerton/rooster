//
//  DividerView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import Cocoa

class DividerView : NSView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

        let view = NSView()
        self.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
//            Theme(for: view).borderColor.cgColor
        
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let indent:CGFloat = 0
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(indent * 2)),
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: indent),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: indent),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
