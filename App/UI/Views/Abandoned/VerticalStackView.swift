//
//  VerticalStackView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class VerticalStackView : UIView {
    
    static let defaultCellHeight:CGFloat = 20
    
    enum HorizontalAlignment {
        case left
        case right
        case fill
        case center
    }
    
    struct Layout {
        
        let defaultCellHeight: CGFloat
        let padding: CGFloat
        let insets: UIEdgeInsets
        
        init(defaultCellHeight: CGFloat = VerticalStackView.defaultCellHeight,
             padding: CGFloat = 0 ,
             insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
            
            self.defaultCellHeight = defaultCellHeight
            self.padding = padding
            self.insets = insets
        }
    }
    
    struct CellLayout {
        
        let alignment: HorizontalAlignment
        let size: CGSize
        
        init(height: CGFloat = 0, // will use stack default
             width: CGFloat = 0,
             alignment: HorizontalAlignment = .fill) {
                     
            self.alignment = alignment
            self.size = CGSize(width: width, height: height)
        }
    }
     
    var layout: Layout {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    class ViewInfo {
        let view: UIView
        var constraints: [NSLayoutConstraint]
        let layout: CellLayout
        
        init(view: UIView,
             layout: CellLayout) {
            self.view = view
            self.layout = layout
            self.constraints = []
        }
    }
    
    private var observations: [NSKeyValueObservation] = []
    private var stackedViews: [ViewInfo] = []
    
    init() {
        self.layout = Layout()
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    init(layout: Layout = Layout()) {
        self.layout = layout
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    init(frame: CGRect,
         layout: Layout = Layout()) {
        self.layout = layout
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func sizeThatFits(_ containingSize: CGSize) -> CGSize {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        var size = CGSize(width: containingSize.width, height: 0)
        let subviews = self.subviews
        for view in subviews {
            let frame = view.frame
            
            let bottom = frame.origin.y + frame.size.height
            
            if bottom > size.height {
                size.height = bottom
            }
        }
        
        size.height += ((self.layout.padding * CGFloat(subviews.count - 1)) + self.layout.insets.top + self.layout.insets.bottom)
        
        return size
    }

    override open func sizeToFit() {
        let size = self.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
    }
    
    var debugFrames = false
    
    func drawFrame(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme(for: self).borderColor.cgColor
        view.layer.cornerRadius = 0
    }
    
    override func updateConstraints() {
        
        let insets = self.layout.insets
        
        let stackedViews = self.stackedViews
        
        stackedViews.forEach { (viewInfo) in
            NSLayoutConstraint.deactivate(viewInfo.constraints)
            viewInfo.view.removeConstraints(viewInfo.constraints)
            viewInfo.constraints.removeAll()
        }
        
        var previousView:UIView? = nil
        
        for (index, viewInfo) in stackedViews.enumerated() {

            let view = viewInfo.view
            let layout = viewInfo.layout
           
            if view.isHidden {
                continue
            }
            
            if self.debugFrames {
                self.drawFrame(view: view)
            }
            
            let topPadding = index == 0 ? 0 : self.layout.padding

            let height = layout.size.height == 0 ? self.layout.defaultCellHeight : layout.size.height
            
            viewInfo.constraints.append(view.heightAnchor.constraint(equalToConstant: height))
            
            if previousView == nil {
                viewInfo.constraints.append(view.topAnchor.constraint(equalTo: self.topAnchor,
                                                                      constant: insets.top + topPadding))
            } else {
                viewInfo.constraints.append(view.topAnchor.constraint(equalTo: previousView!.bottomAnchor,
                                                                      constant: insets.top + topPadding))
            }
            
            if layout.alignment != .fill {
                let width = layout.size.width
                if width == 0 {
                    print("Warning: view width == 0, \(view)")
                }
                viewInfo.constraints.append(view.widthAnchor.constraint(equalToConstant: width))
            }
            
            switch layout.alignment {
            case .left:
                viewInfo.constraints.append(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left))
                
            case .right:
                viewInfo.constraints.append(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right))
                
            case .center:
                viewInfo.constraints.append(view.centerXAnchor.constraint(equalTo: self.centerXAnchor))

            case .fill:
                viewInfo.constraints.append(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left))
                viewInfo.constraints.append(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right))
            }
            
            NSLayoutConstraint.activate(viewInfo.constraints)
            
            previousView = view
        }
        super.updateConstraints()
    }
    
    private func observeView(_ view: UIView) {
        
//        weak var weakSelf = self
//        
//        let observation = view.observe(\UIView.isHidden,
//                                  options: [.old, .new]) { (object, change) in
//            
//            weakSelf?.setNeedsUpdateConstraints()
//        }
//        
//        self.observations.append(observation)
    }
    
//    func setStackedViews(_ views: [(view:UIView, alignment:HorizontalAlignment)]) {
//        self.observations.removeAll()
//        self.stackedViews.removeAll()
//        self.subviews.forEach { $0.removeFromSuperview() }
//        views.forEach {
//            self.addStackedView($0.view, alignment: $0.alignment)
//        }
//    }
    
    func addStackedView(_ view: UIView,
                        layout: CellLayout = CellLayout()) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.observeView(view)
        self.addSubview(view)
        self.stackedViews.append(ViewInfo(view: view,
                                          layout: layout))
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }
}
