//
//  CalendarChooserView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import Cocoa

class CalendarChooserView : ContentAwareView {
  
    lazy var bottomBar = BottomBar(frame: CGRect.zero)
    lazy var topBar = CalendarToolbarView()

    init() {
        super.init(frame: CGRect.zero)

        self.addTopBar()
        self.bottomBar.addToView(self)
        
        self.invalidateIntrinsicContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTopBar() {
        let view = self.topBar
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.preferredHeight),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    func addContentView(_ view: NSView) {
        self.addSubview(view, positioned: .below, relativeTo: self.topBar)
        self.invalidateIntrinsicContentSize()
    }
}




