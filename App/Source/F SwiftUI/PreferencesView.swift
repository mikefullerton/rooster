//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation
import SwiftUI
import UIKit

struct PreferencesView: View, Loggable {
    
    init() {
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Spacer()
            
            SoundPrefs()
                .padding(.leading, 40)
            
            Spacer()
            
            Divider()
            
            NotificationPrefs()
                .padding(.leading, 40)
           
            Spacer()
            
            Divider()
            
            DemoButton()
                .padding()
            
        }.padding()
    }
}

struct SoundPrefs: View {
    
    @State var soundPreference1: String = PreferencesController.instance.preferences.sounds.sound(withIndex: 0)
    @State var soundPreference2: String = PreferencesController.instance.preferences.sounds.sound(withIndex: 1)
    @State var soundPreference3: String = PreferencesController.instance.preferences.sounds.sound(withIndex: 2)

    init() {
        
    }
    
    var body: some View {
        Text(self.soundPreference1)

        Text(self.soundPreference2)

        Text(self.soundPreference3)
    }
}

struct NotificationPrefs: View {
    @State var autoOpenLocations: Bool = PreferencesController.instance.preferences.autoOpenLocations
    @State var bounceIconInDock: Bool = PreferencesController.instance.preferences.bounceIconInDock
    @State var useSystemNotifications: Bool = PreferencesController.instance.preferences.useSystemNotifications

    init() {
        
    }
    
    var body: some View {

        CheckBox(title:"Automatically open location URLs",
                  isOn: $autoOpenLocations) { (isOn) in
            
            let prefs = PreferencesController.instance.preferences
            
            PreferencesController.instance.preferences = Preferences(withSounds: prefs.sounds,
                                                                 useSystemNotifications: prefs.useSystemNotifications,
                                                                 bounceIconInDock: prefs.useSystemNotifications,
                                                                 autoOpenLocations: isOn)
                
        }
    
        CheckBox(title:"Bounce Icon in Dock",
                  isOn: $bounceIconInDock) { (isOn) in
            
            let prefs = PreferencesController.instance.preferences

            PreferencesController.instance.preferences = Preferences(withSounds: prefs.sounds,
                                                                 useSystemNotifications: prefs.useSystemNotifications,
                                                                 bounceIconInDock: isOn,
                                                                 autoOpenLocations: prefs.autoOpenLocations)
                
        }
    
        CheckBox(title:"Use System Notifications",
                  isOn: $useSystemNotifications) { (isOn) in

            let prefs = PreferencesController.instance.preferences

            PreferencesController.instance.preferences = Preferences(withSounds: prefs.sounds,
                                                                 useSystemNotifications: isOn,
                                                                 bounceIconInDock: prefs.bounceIconInDock,
                                                                 autoOpenLocations: prefs.autoOpenLocations)
                
        }
        

    }
}


struct DemoButton: View {
    
    @State var isDemoing: Bool = false
    
    init() {
        
    }

    let imageSize:CGFloat = 26.0
    

        
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                PreferencesController.instance.preferences = Preferences.defaults
            }) {
                SystemImageButtonBody(imageName: "arrow.triangle.2.circlepath", imageSize: CGSize(width: 36, height: 36))
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: self.imageSize * 3, height: self.imageSize, alignment: .leading)

            Spacer()
            if self.isDemoing {
                
                Button(action: {
                    self.isDemoing = false
                    AlarmNotificationController.instance.stopAllNotifications()
                }) {
                    ImageButtonBody(imageName: "RedRoosterIcon",
                                    color:nil,
                                    text: "Stop")
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: self.imageSize * 3, height: self.imageSize, alignment: .leading)
            } else {
                
                Button(action: {
                    self.isDemoing = true
                    AlarmNotificationController.instance.schedule(notification: DemoAlarmNotification())
                }) {
                    ImageButtonBody(imageName: "RedRoosterIcon",
                                    color:nil,
                                    text: "Try it!")

                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: self.imageSize * 3, height: self.imageSize, alignment: .leading)
            }
            Spacer()
        }
    }
}

struct SystemImageButtonBody: View {
    
    let imageName: String
    let imageSize: CGSize
    
    var body: some View {
        VStack {
            Image(systemName: self.imageName)
//                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: self.imageSize.width,
                       height: self.imageSize.height,
                       alignment: .center)
                .scaledToFit()

            Text("Reset")
                .font(.system(.footnote))
                .foregroundColor(Color(UIColor.label))
        }
    }
    
    
}

struct ImageButtonBody: View {
    
    let imageName: String
    let color: Color?
    let text: String
    
    var body: some View {
        VStack {
            Image(self.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)

            Text(self.text)
                .font(.system(.footnote))
                .foregroundColor(Color(UIColor.label))
        }
    }
    
    
}

