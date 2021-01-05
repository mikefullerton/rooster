//
//  CalendarChooserView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import UIKit

class CalendarChooserView : UIView {
  
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
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

    }

    override var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero
        
        for view in self.subviews {
            
            let viewSize = view.intrinsicContentSize
            
            if viewSize.width > outSize.width {
                outSize.width = viewSize.width
            }

            if viewSize.height > outSize.height {
                outSize.height = viewSize.height
            }
        }
        
        return outSize
        
    }

    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        
        if view != self.topBar {
            self.bringSubviewToFront(self.topBar)
        }
        
        if view != self.bottomBar {
            self.bringSubviewToFront(self.bottomBar)
        }
        
        self.invalidateIntrinsicContentSize()
    }
}




