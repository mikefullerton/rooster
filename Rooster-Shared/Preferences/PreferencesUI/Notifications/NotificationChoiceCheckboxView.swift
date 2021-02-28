//
//  NotificationChoiceCheckBox.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class NotificationChoiceCheckboxView : SinglePreferenceChoiceView {
    
    let options: SingleNotificationPreference.Options
    let notificationPreferenceKey: NotificationPreferences.PreferenceKey
    
    init(withTitle title: String,
         notificationPreferenceKey: NotificationPreferences.PreferenceKey,
         options: SingleNotificationPreference.Options) {
        
        self.notificationPreferenceKey = notificationPreferenceKey
        self.options = options
        super.init(frame: CGRect.zero, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var preference: SingleNotificationPreference {
        get {
            return Controllers.preferencesController.notificationPreferences.preference(forKey: self.notificationPreferenceKey)
        }
        set(newPref) {
            Controllers.preferencesController.notificationPreferences.setPreference(newPref, forKey: self.notificationPreferenceKey)
        }
    }

    @objc override func checkboxChanged(_ sender: NSButton) {
        var prefs = self.preference
        
        if sender.intValue == 1 {
            prefs.options.insert(self.options)
        } else {
            prefs.options.remove(self.options)
        }
        
        self.preference = prefs
    }
    
    override var value: Bool {
        return self.preference.options.contains(self.options)
    }
}



