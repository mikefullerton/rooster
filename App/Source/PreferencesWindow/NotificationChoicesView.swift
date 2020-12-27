//
//  NotificationChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class NotificationChoicesView : GroupBoxView {
    
    init() {
        super.init(frame: CGRect.zero,
                  title: "Notifications" )
        
        self.addTopSubview(view: self.automaticallyOpenLocationURLs)
        self.addSubview(view: self.bounceIconInDock, belowView: self.automaticallyOpenLocationURLs)
        self.addSubview(view: self.useSystemNotifications, belowView: self.bounceIconInDock)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func preferenceSettingChanged(_ sender: UISwitch) {
        
    }
    
    private func createCheckBox(withTitle title: String) -> UISwitch {
        let view = UISwitch()
        view.title = title
        
        #if targetEnvironment(macCatalyst)
        view.preferredStyle = .checkbox
        #endif

        view.addTarget(self, action: #selector(preferenceSettingChanged(_:)), for: .valueChanged)
        self.addSubview(view)
    
        return view
    }
    
    lazy var automaticallyOpenLocationURLs : UISwitch = {
        let view = self.createCheckBox(withTitle:"Automatically open location URLs")
        return view
    }()

    lazy var bounceIconInDock : UISwitch = {
        let view = self.createCheckBox(withTitle:"Bounce Icon in Dock")
        return view
    }()

    lazy var useSystemNotifications : UISwitch = {
        let view = self.createCheckBox(withTitle:"Use System Notifications")
        return view
    }()
    
    
    
}
