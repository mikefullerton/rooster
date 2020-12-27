//
//  UIView+MyLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

struct Layout {
    static let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    static let padding:CGFloat = 10.0
    
    static let width:CGFloat = 400
}

extension UIView {
    
    
    @objc func addTopSubview(view: UIView) {
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.sizeToFit()
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Layout.insets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Layout.insets.right),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.insets.top),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        ])
    }
    
    @objc func addSubview(view: UIView, belowView: UIView) {
        
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.sizeToFit()
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Layout.insets.left),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Layout.insets.right),
            view.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: Layout.padding),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        ])
    }
    
    func calculateLayoutSize(withInsets insets: UIEdgeInsets) -> CGSize {
        
        // make sure the view is loaded
        for view in self.subviews {
            view.sizeToFit()
        }
            
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        var outSize = CGSize.zero
        
        print("caculating size for: \(self)")
        for view in self.subviews {
            let viewBottom = view.frame.origin.y + view.frame.size.height
            if viewBottom > outSize.height {
                outSize.height = viewBottom

                print("updated size: \(outSize) for view: \(view)")
            }
            
            let width = view.frame.origin.x + view.frame.size.width
            if width > outSize.width {
                outSize.width = width
            
                print("updated size: \(outSize) for view: \(view)")
            }
            
            
        }
        
        outSize.height += insets.bottom
        outSize.width += insets.right
    
        print("done caculating size for: \(self): size: \(outSize)")
        
        return outSize
    }

}
