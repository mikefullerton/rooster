//
//  ListViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

class AbstractListViewRowView: SDKCollectionViewItem {
    class var preferredHeight:CGFloat {
        return 0
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState {
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
    
    var isHighlightable: Bool = false {
        didSet {
            if self.isHighlightable && self.highlightBackgroundView == nil {
                self.addHighlightBackgroundView()
            }
        }
    }
    
    var highlightBackgroundView: NSVisualEffectView? = nil
    
    func addHighlightBackgroundView() {
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
    
    func setConstraintsForHighlightBackgroundView() {
        if let view = self.highlightBackgroundView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    override var isSelected: Bool {
        get { return super.isSelected }
        set(selected) {
            super.isSelected = selected
        }
    }
}

class ListViewRowView<CONTENT_TYPE> : AbstractListViewRowView {
    typealias contentType = CONTENT_TYPE
    
    func viewWillAppear(withContent content: CONTENT_TYPE) {
        
    }
}

protocol AbstractListViewRowDescriptor {
    var viewClass: AbstractListViewRowView.Type { get }
    func willDisplayView(_ view: SDKCollectionViewItem)
}

extension AbstractListViewRowDescriptor {
    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.viewClass)"
    }

    var height: CGFloat {
        return self.viewClass.preferredHeight
    }
}

struct ListViewRowDescriptor<CONTENT_TYPE, VIEW_TYPE: AbstractListViewRowView>: AbstractListViewRowDescriptor {
    let content: CONTENT_TYPE
    
    let eventHandler: EventHandler?
    
    init(withContent content: CONTENT_TYPE,
         eventHandler: EventHandler? = nil) {
        self.content = content
        self.eventHandler = eventHandler
    }
    
    func willDisplayView(_ view: SDKCollectionViewItem) {
        if let cell = view as? ListViewRowView<CONTENT_TYPE> {
            cell.viewWillAppear(withContent: self.content)
        }
    }
    
    var viewClass: AbstractListViewRowView.Type {
        return VIEW_TYPE.self
    }
}

