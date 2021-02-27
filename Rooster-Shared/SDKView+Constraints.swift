//
//  SDKView+Constraints.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import RoosterCore
import RoosterCore


enum SubviewAlignment {
    case left
    case right
    case center
}

extension SDKView {

    func setPositionalContraints(forSubview view: NSView,
                                 alignment: SubviewAlignment) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.deactivate(view.constraints)
        
        var constraints: [NSLayoutConstraint] = []
        
        switch(alignment) {
        case .left:
            constraints = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ]

        case .right:
            constraints = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ]

        case .center:
            constraints = [
                view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ]
        }
        
        constraints.forEach { $0.priority = .required }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setIntrinsicSizeConstraints(forSubview view: NSView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
        ])
    }

    func setFillInParentConstraints(forSubview view: NSView,
                                    insets: SDKEdgeInsets = SDKEdgeInsets.zero) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: insets.left),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom),
        ])
    }

}
