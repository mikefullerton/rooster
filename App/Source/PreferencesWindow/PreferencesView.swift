//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation
import SwiftUI

struct ButtonModifier : ViewModifier {
    let kButtonWidth: CGFloat = 80.0
    let kButtonHeight: CGFloat = 40.0

    let buttonTextColor: Color
    
    init(withButtonTextColor buttonTextColor: Color) {
        self.buttonTextColor = buttonTextColor
    }
    
    func body(content: Content) -> some View {
            content
                .frame(width: kButtonWidth, height: kButtonHeight, alignment: .center)
                .foregroundColor(self.buttonTextColor)
                .background(Color.gray)
                .cornerRadius(40)
                .buttonStyle(BorderlessButtonStyle())
        }
}

struct PreferencesView: View, Loggable {

    @ObservedObject var preferencesController = PreferencesController.instance
    
    @State var preferences: Preferences = PreferencesController.instance.preferences
    
    @State var autoOpenLocations: Bool = PreferencesController.instance.preferences.autoOpenLocations
    @State var bounceIconInDock: Bool = PreferencesController.instance.preferences.bounceIconInDock
    @State var useSystemNotifications: Bool = PreferencesController.instance.preferences.useSystemNotifications

    init() {
//        self.preferences = preferences
//        self.autoOpenLocations = preferences.autoOpenLocations
//        self.bounceIconInDock = preferences.bounceIconInDock
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CheckBox3(title:"Automatically open location URLs",
                      isOn: $autoOpenLocations) { (isOn) in
                
                self.preferencesController.preferences = Preferences(withSounds: self.preferences.sounds,
                                                                     useSystemNotifications: self.preferences.useSystemNotifications,
                                                                     bounceIconInDock: self.preferences.useSystemNotifications,
                                                                     autoOpenLocations: isOn)
                    
            }
            CheckBox3(title:"Bounce Icon in Dock",
                      isOn: $bounceIconInDock) { (isOn) in
                
                self.preferencesController.preferences = Preferences(withSounds: self.preferences.sounds,
                                                                     useSystemNotifications: self.preferences.useSystemNotifications,
                                                                     bounceIconInDock: isOn,
                                                                     autoOpenLocations: self.preferences.autoOpenLocations)
                    
            }
            CheckBox3(title:"Use System Notifications",
                      isOn: $useSystemNotifications) { (isOn) in
                
                self.preferencesController.preferences = Preferences(withSounds: self.preferences.sounds,
                                                                     useSystemNotifications: isOn,
                                                                     bounceIconInDock: self.preferences.bounceIconInDock,
                                                                     autoOpenLocations: self.preferences.autoOpenLocations)
                    
            }

        }.padding()
    }
}

//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferencesView()
//    }
//}
