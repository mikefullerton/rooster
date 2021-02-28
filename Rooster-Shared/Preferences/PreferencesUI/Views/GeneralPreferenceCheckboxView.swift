//
//  GeneralPreferenceCheckboxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class GeneralPreferenceCheckboxView : SinglePreferenceChoiceView {
    
    private var options: GeneralPreferences.Options
    
    public init(withTitle title: String,
         options: GeneralPreferences.Options) {
        
        self.options = options
        super.init(frame: CGRect.zero, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var preference: GeneralPreferences {
        get {
            return Controllers.preferencesController.generalPreferences
        }
        set(newPref) {
            Controllers.preferencesController.generalPreferences = newPref
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
    
    public override var value: Bool {
        return self.preference.options.contains(self.options)
    }
}

