//
//  NotificationChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import Cocoa

class NotificationChoiceView : NSView {
    
    let title: String
    
    init(frame: CGRect,
         title: String) {
        
        self.title = title
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.checkbox.title = title
        self.addSubview(self.checkbox)
        
        self.needsUpdateConstraints = true
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
    
    @objc func checkboxChanged(_ sender: NSButton) {
    }
    
    lazy var checkbox : NSButton = {
        let view = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkboxChanged(_:)))
        view.intValue = self.value ? 1 : 0
        return view
    }()
    
    lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets: NSEdgeInsets.zero,
                                  spacing: Offset.zero)
        
    }()
    
    var value: Bool { return false }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
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
    
    @objc override func checkboxChanged(_ sender: NSButton) {

        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.autoOpenLocations = sender.intValue == 1
        AppDelegate.instance.preferencesController.preferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.autoOpenLocations
    }

    lazy var locationTipView : TipView = {
        
        var locationTip = Tip(image: NSImage(systemSymbolName: "info.circle.fill", accessibilityDescription: "info.circle.fill"),
                              imageTintColor: NSColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)
        
        let view = TipView(frame: CGRect.zero, tip: locationTip)
        return view
    }()
    
    override func refresh() {
        self.checkbox.intValue = AppDelegate.instance.preferencesController.preferences.autoOpenLocations ? 1 : 0
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

    @objc override func checkboxChanged(_ sender: NSButton) {
        
        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.bounceIconInDock = sender.intValue == 1
        AppDelegate.instance.preferencesController.preferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.bounceIconInDock
    }
    
    override func refresh() {
        self.checkbox.intValue = AppDelegate.instance.preferencesController.preferences.bounceIconInDock ? 1 : 0
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

    @objc override func checkboxChanged(_ sender: NSButton) {
        
        var prefs = AppDelegate.instance.preferencesController.preferences
        prefs.useSystemNotifications = sender.intValue == 1
        AppDelegate.instance.preferencesController.preferences = prefs
    }

    override var value: Bool {
        return AppDelegate.instance.preferencesController.preferences.useSystemNotifications
    }
    
    override func refresh() {
        self.checkbox.intValue = AppDelegate.instance.preferencesController.preferences.useSystemNotifications ? 1 : 0
    }


}
