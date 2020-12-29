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
        
        self.layout.addSubview(self.checkbox)
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
    
    lazy var layout: ViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets: UIEdgeInsets.zero,
                                  spacing: UIOffset.zero)
        
    }()
    
    var value: Bool { return false }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.layout.size.height
        
        print("Layout Size: \(outSize) for \(self)")
        print("Views: \(self.subviews)")
        return outSize
    }
}

class AutomaticallyOpenLocationURLsChoiceView : NotificationChoiceView {
    
    
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "AUTO_OPEN_LOCATIONS".localized)
        
        self.layout.addSubview(self.locationTipView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: UISwitch) {

        var prefs = PreferencesController.instance.preferences
        prefs.autoOpenLocations = sender.isOn
        PreferencesController.instance.preferences = prefs
    }
    
    override var value: Bool {
        return PreferencesController.instance.preferences.autoOpenLocations
    }

    lazy var locationTipView : TipView = {
        
        var locationTip = Tip(image: UIImage(systemName: "info.circle.fill"),
                              imageTintColor: UIColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)
        
        let view = TipView(frame: CGRect.zero, tip: locationTip)
        
//        self.addSubview(view)
//
//        let viewSize = view.sizeThatFits(CGSize(width: 1000, height: 1000))
//
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            view.topAnchor.constraint(equalTo: self.topAnchor),
//            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
//
//        NSLayoutConstraint.activate([
//            view.heightAnchor.constraint(equalToConstant: viewSize.height)
//        ])

        return view
    }()
    
    func showLocationTipIfNeeded() {
//        if PreferencesController.instance.preferences.autoOpenLocations {
//            NSLayoutConstraint.activate([
//                self.locationTipView.heightAnchor.constraint(equalToConstant: self.locationTipView.frame.size.height)
//            ])
//        } else {
//            NSLayoutConstraint.activate([
//                self.locationTipView.heightAnchor.constraint(equalToConstant: 0)
//            ])
//        }
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
        
        var prefs = PreferencesController.instance.preferences
        prefs.bounceIconInDock = sender.isOn
        PreferencesController.instance.preferences = prefs
        
        if sender.isOn {
            AppKitPluginController.instance.utilities.bounceAppIconOnce()
        }
    }
    
    override var value: Bool {
        return PreferencesController.instance.preferences.bounceIconInDock
    }
}


class UseSystemNotificationsChoiceView : NotificationChoiceView {

    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "USE_SYSTEM_NOTIFICATIONS".localized)
    
        self.layout.addSubview(self.button)
    }
    
    @objc func buttonPressed(_ sender: UISwitch) {
//        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
//                                  options: [:],
//                                  completionHandler: nil)
        
        AppKitPluginController.instance.utilities.openNotificationSettings()
    }

    lazy var button: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "speaker.wave.2"))
        button.frame = self.bounds
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
//        button.tag = index
        
//        self.addSubview(button)
//
//        button.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            button.widthAnchor.constraint(equalToConstant: self.buttonHeight),
//            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
//            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        ])
        
        return button
    }()

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: UISwitch) {
        
        var prefs = PreferencesController.instance.preferences
        prefs.useSystemNotifications = sender.isOn
        PreferencesController.instance.preferences = prefs
    }

    override var value: Bool {
        return PreferencesController.instance.preferences.useSystemNotifications
    }

}
