//
//  PreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

open class PreferencePanel : SDKViewController, Loggable {

    open var toolbarButtonIdentifier: String {
        return ""
    }

//    convenience init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//
//    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }
    
    open func refresh() {
        
    }
    
    open func resetButtonPressed() {
        Controllers.preferences.preferences = Preferences.default
    }

}

