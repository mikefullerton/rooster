//
//  ViewLayout+Vertical.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit


struct VerticalViewLayout : ViewLayout {
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

    private func addTopSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        let size = view.sizeThatFits(CGSize(width: self.hostView.frame.size.width,
                                            height: CGFloat.greatestFiniteMagnitude))
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            view.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: self.insets.top),
            
            view.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    private func addSubview(_ view: UIView, belowView: UIView) {
        
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(CGSize(width: self.hostView.frame.size.width,
                                            height: CGFloat.greatestFiniteMagnitude))
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            view.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: self.spacing.vertical),
            
            view.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    func addSubview(_ view: UIView) {
        if self.hostView.subviews.count == 0 {
            self.addTopSubview(view)
        } else {
            self.addSubview(view, belowView: self.hostView.subviews.last!)
        }
    }
}


