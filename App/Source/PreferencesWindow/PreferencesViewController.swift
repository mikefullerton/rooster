//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit
import SwiftUI

class PreferencesViewController : UIViewController {
    
    let preferencesView: UIHostingController<PreferencesView>
    
    init() {
        self.preferencesView = UIHostingController<PreferencesView>(rootView:PreferencesView())
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(self.preferencesView)
        
        let subview = self.preferencesView.view!
        
        self.view.addSubview(subview)

        subview.translatesAutoresizingMaskIntoConstraints = false
        
        subview.sizeToFit()
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            subview.topAnchor.constraint(equalTo: self.view.topAnchor),
            subview.heightAnchor.constraint(equalToConstant: subview.frame.size.height)
        ])
    }
    
//    let popoverWidth: CGFloat = 400
    
    var calculatedSize: CGSize {
        // make sure the view is loaded
        let _ = self.view
        return self.preferencesView.view.frame.size
    }
}
