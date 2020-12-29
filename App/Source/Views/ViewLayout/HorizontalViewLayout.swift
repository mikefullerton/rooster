//
//  ViewLayout+Horizontal.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

struct HorizontalViewLayout: ViewLayout {
    
    let hostView: UIView
    let insets:UIEdgeInsets
    let spacing:UIOffset

    init(hostView view: UIView,
         insets: UIEdgeInsets,
         spacing: UIOffset) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
    }
    
    private func addLeadingSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.widthAnchor.constraint(equalToConstant: size.width),
            
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left)
        ])
    }
    
    private func addSubview(_ view: UIView, nextTo: UIView) {
        
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.widthAnchor.constraint(equalToConstant: size.width),
            view.leadingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: self.spacing.horizontal)
        ])
    }
    
    func addSubview(_ view: UIView) {
        if self.hostView.subviews.count == 0 {
            self.addLeadingSubview(view)
        } else {
            self.addSubview(view, nextTo: self.hostView.subviews.last!)
        }
    }
}

