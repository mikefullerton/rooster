//
//  VerticalStackedViewLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import UIKit

struct ViewLayoutSpec {
    let insets:UIEdgeInsets
    let verticalViewSpacing:CGFloat
    let width:CGFloat

    init(insets: UIEdgeInsets,
         verticalViewSpacing: CGFloat,
         width: CGFloat) {
        self.insets = insets
        self.verticalViewSpacing = verticalViewSpacing
        self.width = width
    }
    
    init(width: CGFloat) {
        self.init(insets: UIEdgeInsets.zero,
                  verticalViewSpacing: 0,
                  width: 0)
    }
    
    static var `default`: ViewLayoutSpec {
        ViewLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
               verticalViewSpacing: 10.0,
               width: 400)
    }
    
    static var zero: ViewLayoutSpec {
        ViewLayoutSpec(insets: UIEdgeInsets.zero, verticalViewSpacing: 0, width: 0)
    }
}

struct VerticalStackedViewLayout {
    
    
//    private(set) var subviews:[UIView] = []
    let hostView: UIView
    let layoutSpec: ViewLayoutSpec
    
    init(hostView view: UIView,
         layoutSpec: ViewLayoutSpec) {
        self.hostView = view
        self.layoutSpec = layoutSpec
    }
    
    private func addTopSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        
//        self.subviews.append(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        let size = view.sizeThatFits(CGSize(width: self.layoutSpec.width,
                                            height: 1000))
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.layoutSpec.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.layoutSpec.insets.right),
            view.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: self.layoutSpec.insets.top),
            
            view.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
    
    private func addSubview(_ view: UIView, belowView: UIView) {
        
        self.hostView.addSubview(view)

//        self.subviews.append(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        let size = view.sizeThatFits(CGSize(width: self.layoutSpec.width,
                                            height: 1000))
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.layoutSpec.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.layoutSpec.insets.right),
            view.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: self.layoutSpec.verticalViewSpacing),
            
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
    
//    func addSubviews(_ views: [UIView],
//                     belowView: UIView? = nil) {
//
//        var lastView = belowView
//
//        for view in views {
//
//            if let viewAbove = lastView {
//                self.addSubview(view, belowView: viewAbove)
//            } else {
//                self.addTopSubview(view)
//            }
//
//            lastView = view
//        }
//    }
    
    var layoutSize: CGSize {
        
        // make sure the view is loaded
//        for view in self.hostView.subviews {
//            view.sizeToFit()
//        }
            
        self.hostView.setNeedsLayout()
        self.hostView.layoutIfNeeded()
        
        var outSize = CGSize(width: self.layoutSpec.width, height: 0)
        
        print("caculating size for: \(self)")
        for view in self.hostView.subviews {
            let viewBottom = view.frame.origin.y + view.frame.size.height
            if viewBottom > outSize.height {
                outSize.height = viewBottom

                print("updated size: \(outSize) for view: \(view)")
            }
            
//            let width = view.frame.origin.x + view.frame.size.width
//            if width > outSize.width {
//                outSize.width = width
//
//                print("updated size: \(outSize) for view: \(view)")
//            }
            
            
        }
        
        outSize.height += self.layoutSpec.insets.bottom
//        outSize.width += self.layoutSpec.insets.right
    
        print("done caculating size for: \(self): size: \(outSize)")
        
        return outSize
    }
    
    
}
