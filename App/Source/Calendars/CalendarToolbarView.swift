//
//  CalendarToolbarView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import UIKit

class CalendarToolbarView : TopBar {
    
    let insets = UIEdgeInsets.twenty
        
//    override var preferredHeight: CGFloat {
//        return 80.0
//    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.addToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        
        var appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        toolbar.standardAppearance = appearance
        
        let placeholder = UIBarButtonItem(title: "placeholder",
                                                  style: .plain,
                                                  target: nil,
                                                  action: nil)
        toolbar.items = [ UIBarButtonItem.flexibleSpace(), placeholder, placeholder,  UIBarButtonItem.flexibleSpace()]
        return toolbar
    }()
    
    private func addToolbar() {

        let toolbar = self.toolbar
        
        self.addSubview(toolbar)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: self.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        self.invalidateIntrinsicContentSize()
    }
}
