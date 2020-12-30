//
//  ViewLayout+Horizontal.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

struct HorizontalViewLayout: ViewLayout {
    
    enum Alignment {
        case left
        case right
    }
    
    let hostView: UIView
    let insets:UIEdgeInsets
    let spacing:UIOffset
    let alignment:Alignment

    init(hostView view: UIView,
         insets: UIEdgeInsets,
         spacing: UIOffset,
         alignment: Alignment = .left) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.alignment = alignment
    }
    
    private func addLeadingSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.widthAnchor.constraint(equalToConstant: size.width),
        ])
        
        switch(self.alignment) {
        case .left:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left)
            ])
        
        case .right:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right)
            ])
        }
    }
    
    private func addSubview(_ view: UIView, nextTo: UIView) {
        
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.widthAnchor.constraint(equalToConstant: size.width),
        ])
        
        switch(self.alignment) {
        case .left:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: self.spacing.horizontal)
            ])
        
        case .right:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: -self.spacing.horizontal)
            ])
        }
    }
    
    func addSubview(_ view: UIView) {
        if self.hostView.subviews.count == 0 {
            self.addLeadingSubview(view)
        } else {
            self.addSubview(view, nextTo: self.hostView.subviews.last!)
        }
    }
}

