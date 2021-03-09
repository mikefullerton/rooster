//
//  DataModelCheckboxView.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/24/21.
//

import Foundation
import RoosterCore

//public class DataModelCheckboxView : SinglePreferenceChoiceView {
//    
//    private var options: GeneralPreferences.Options
//    
//    public init(withTitle title: String,
//                options: GeneralPreferences.Options) {
//        
//        self.options = options
//        super.init(frame: CGRect.zero, title: title)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    public var preference: GeneralPreferences {
//        get {
//            return Controllers.preferences.general
//        }
//        set(newPref) {
//            Controllers.preferences.general = newPref
//        }
//    }
//
//    @objc override func checkboxChanged(_ sender: SDKSwitch) {
//        var prefs = self.preference
//        
//        if sender.isOn {
//            prefs.options.insert(self.options)
//        } else {
//            prefs.options.remove(self.options)
//        }
//        
//        self.preference = prefs
//    }
//    
//    public override var value: Bool {
//        return self.preference.options.contains(self.options)
//    }
//}
//
