//
//  NotificationChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import UIKit

class NotificationChoiceView : UIView {
    
    let title: String
    
    init(frame: CGRect,
         title: String) {
        
        self.title = title
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.addSubview(self.checkbox)
        
        self.setNeedsUpdateConstraints()
        self.refresh()
    }
    
    override func updateConstraints() {
        self.addViewsToLayout()
        super.updateConstraints()
    }

    func addViewsToLayout() {
        self.layout.setViews([ self.checkbox ])
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }

    func refresh() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func checkboxChanged(_ sender: UISwitch) {
    }
    
    lazy var checkbox : UISwitch = {
        let view = UISwitch(frame: self.bounds)
        view.title = title
        
        #if targetEnvironment(macCatalyst)
        view.preferredStyle = .checkbox
        #endif

        view.isOn = self.value
        
        view.addTarget(self, action: #selector(checkboxChanged(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets: UIEdgeInsets.zero,
                                  spacing: UIOffset.zero)
        
    }()
    
    var value: Bool { return false }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }
}

class AutomaticallyOpenLocationURLsChoiceView : NotificationChoiceView {
    
    
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "AUTO_OPEN_LOCATIONS".localized)
        
        self.addSubview(self.locationTipView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addViewsToLayout() {
        self.layout.setViews([ self.checkbox,
                               self.locationTipView])
    }
    
    @objc override func checkboxChanged(_ sender: UISwitch) {

        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.autoOpenLocations = sender.isOn
        AppDelegate.instance.preferencesController.preferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.autoOpenLocations
    }

    lazy var locationTipView : TipView = {
        
        var locationTip = Tip(image: UIImage(systemName: "info.circle.fill"),
                              imageTintColor: UIColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)
        
        let view = TipView(frame: CGRect.zero, tip: locationTip)
        return view
    }()
    
    override func refresh() {
        self.checkbox.isOn = AppDelegate.instance.preferencesController.preferences.autoOpenLocations
    }
}


class BounceInDockChoiceView : NotificationChoiceView {
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "BOUNCE_ICON".localized)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: UISwitch) {
        
        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.bounceIconInDock = sender.isOn
        AppDelegate.instance.preferencesController.preferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.bounceIconInDock
    }
    
    override func refresh() {
        self.checkbox.isOn = AppDelegate.instance.preferencesController.preferences.bounceIconInDock
    }

}


class UseSystemNotificationsChoiceView : NotificationChoiceView {

    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "USE_SYSTEM_NOTIFICATIONS".localized)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: UISwitch) {
        
        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.useSystemNotifications = sender.isOn
        AppDelegate.instance.preferencesController.preferences = prefs
    }

    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.useSystemNotifications
    }
    
    override func refresh() {
        self.checkbox.isOn = AppDelegate.instance.preferencesController.preferences.useSystemNotifications
    }


}
