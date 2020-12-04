//
//  StackViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

class StackViewCell : UIView {
    private(set) var enclosedView: UIView? = nil
    
    enum HorizontalAlignment {
        case left
        case right
        case fill
        case center
    }
    
    enum VerticalAlignment {
        case top
        case bottom
        case fill
        case center
    }
    
    struct CellLayout {
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let insets: UIEdgeInsets
        
        init(horizontalAlignment: HorizontalAlignment = .fill,
             verticalAlignment: VerticalAlignment = .fill,
             insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
            
            self.horizontalAlignment = horizontalAlignment
            self.verticalAlignment = verticalAlignment
            self.insets = insets
        }
    }
    
    convenience init(enclosedView: UIView,
                     layout: CellLayout ) {
        self.init(frame: enclosedView.frame, enclosedView: enclosedView, layout: layout)
    }
    
    init(frame: CGRect,
         enclosedView: UIView,
         layout: CellLayout ) {
        super.init(frame: frame)

        self.setEnclosedView(view: enclosedView, layout: layout)
    }
    
    var intrinsicSize: CGSize = CGSize(width: 0, height: 0)
    
    override var intrinsicContentSize: CGSize {
        return self.intrinsicSize
    }
    
    func setEnclosedView(view: UIView, layout: CellLayout) {
       
        if self.enclosedView != nil {
            self.enclosedView?.removeFromSuperview()
        }
        
        self.addSubview(view)
        
        var newIntrinsicSize = CGSize(width: 0, height: 0)
        
        view.translatesAutoresizingMaskIntoConstraints = false
       
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(view.centerYAnchor.constraint(equalTo: self.centerYAnchor))

        if layout.verticalAlignment != .fill {
            let height = view.frame.size.height
            if height == 0 {
                print("Warning: view height == 0, \(view)")
            }
            newIntrinsicSize.height = height + 10
            constraints.append(view.widthAnchor.constraint(equalToConstant: height))
        }
        
        switch layout.verticalAlignment {
        case .top:
            constraints.append(view.topAnchor.constraint(equalTo: self.topAnchor,
                                                             constant: layout.insets.top))
            
        case .bottom:
            constraints.append(view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -layout.insets.bottom))
            
        case .center:
            constraints.append(view.centerYAnchor.constraint(equalTo: self.centerYAnchor))

        case .fill:
            constraints.append(view.topAnchor.constraint(equalTo: self.topAnchor, constant: layout.insets.top))
            constraints.append(view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -layout.insets.bottom))
        }
        
        if layout.horizontalAlignment != .fill {
            let width = view.frame.size.width
            if width == 0 {
                print("Warning: view width == 0, \(view)")
            }
            newIntrinsicSize.width = width + 10
            constraints.append(view.widthAnchor.constraint(equalToConstant: width))
        }
        
        switch layout.horizontalAlignment {
        case .left:
            constraints.append(view.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                             constant: layout.insets.left))
            
        case .right:
            constraints.append(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -layout.insets.right))
            
        case .center:
            constraints.append(view.centerXAnchor.constraint(equalTo: self.centerXAnchor))

        case .fill:
            constraints.append(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: layout.insets.left))
            constraints.append(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -layout.insets.right))
        }
     
        self.intrinsicSize = newIntrinsicSize
        
        NSLayoutConstraint.activate(constraints)
       
    }
    
//
//    override var frame: CGRect {
//        get { return super.frame }
//        set(value) {
//            super.frame = value
//            self._intrinsicContentSize = value.size
//        }
//    }
//
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
