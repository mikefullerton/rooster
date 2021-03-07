//
//  AbstractListViewRowView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
import RoosterCore

open class AbstractListViewRowController: SDKCollectionViewItem, Loggable {
    
    public class var preferredSize: CGSize {
        return CGSize.zero
    }
    
    public override var highlightState: NSCollectionViewItem.HighlightState {
        get { return super.highlightState }
        set(state) {
            if !self.isHighlightable {
                super.highlightState = .none
                return
            }
            
            super.highlightState = state
            
            switch(state) {
            case .none:
                self.highlightBackgroundView?.isHidden = true
                
            case .forSelection:
                self.highlightBackgroundView?.isHidden = false
                
            case .forDeselection:
                self.highlightBackgroundView?.isHidden = false

            case .asDropTarget:
                self.highlightBackgroundView?.isHidden = false
            
            @unknown default:
                self.highlightBackgroundView?.isHidden = true
            }
        
//            print("tracking: highlight state: \(state.rawValue), \(Date().shortDateAndLongTimeString), \(self.highlightBackgroundView)")
            
            self.view.needsDisplay = true
        }
    }
    
    public var isHighlightable: Bool = false {
        didSet {
            if self.isHighlightable && self.highlightBackgroundView == nil {
                self.addHighlightBackgroundView()
            }
        }
    }
    
    public var highlightBackgroundView: NSVisualEffectView? = nil
    
    public func addHighlightBackgroundView() {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .selection
        view.isEmphasized = true
        view.blendingMode = .behindWindow
        self.highlightBackgroundView = view

        let subviews = self.view.subviews
        if subviews.count > 0 {
            self.view.addSubview(view, positioned: .below, relativeTo: subviews[0] )
        } else {
            self.view.addSubview(view)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        self.setConstraintsForHighlightBackgroundView()
    }
    
    public func setConstraintsForHighlightBackgroundView() {
        if let view = self.highlightBackgroundView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    public override var isSelected: Bool {
        get { return super.isSelected }
        set(selected) {
            super.isSelected = selected
        }
    }
    
    public var rowView: RowView {
        return self.view as! RowView
    }
    
    public override func loadView() {
        let view = RowView()
        self.view = view
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = Self.preferredSize
    }
    
    public override var preferredContentSize: NSSize {
        get {
            let size = super.preferredContentSize
            return size
        }
        set(newSize) {
            super.preferredContentSize = newSize
            self.rowView.preferredSize = newSize
        }
    }
    
    public override func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        if let collectionView = self.collectionView {
            
            var frame = layoutAttributes.frame
            
            var size = self.preferredContentSize
            size.width = collectionView.bounds.size.width
            
            frame.size = size
            frame.origin.x = collectionView.bounds.minX
            
            layoutAttributes.frame = frame
            layoutAttributes.size = size
        }
        
        return layoutAttributes
    }
}
