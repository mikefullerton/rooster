//
//  CheckBox.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import SwiftUI

struct CheckBox: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = UISwitch
    
//    @Binding var calendar: EventKitCalendar
  
    
    @Binding var title: String
    @Binding var isOn: Bool
    var callback: (Bool) -> Void
  
//    init(title: String,
//         isOn: Bool,
//         callback: @escaping (Bool) -> Void) {
//        
//        self.title = title
//        self.isOn = isOn
//        self.callback = callback
//    }
//    
    func makeUIView(context: Context) -> UISwitch {
        let checkbox = UISwitch()
        checkbox.preferredStyle = .checkbox
        
        checkbox.addTarget(context.coordinator,
                           action: #selector(Coordinator.handleToggle(sender:)),
                           for: .valueChanged)
        checkbox.backgroundColor = UIColor.clear
        
        return checkbox
    }
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = self.isOn
        uiView.title = self.title
    }
    
    class Coordinator: NSObject {
       var control: CheckBox

       init(_ control: CheckBox) {
           self.control = control
       }

       @objc func handleToggle(sender: UISwitch) {
            self.control.isOn = sender.isOn
            self.control.callback(sender.isOn)
//        calendar.set(subscribed: sender.isOn)
       }
   }
}

struct CheckBoxView : View {
    
    @Binding var title: String
    @Binding var isOn: Bool

    var body: some View {
        CheckBox(title: $title, isOn: $isOn) { (Bool) in
            
        }
    }
}

struct CheckBox2: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = UISwitch
    
//    @Binding var calendar: EventKitCalendar
  
    
    var title: String
    var isOn: Bool
    var callback: (Bool) -> Void
  
//    init(title: String,
//         isOn: Bool,
//         callback: @escaping (Bool) -> Void) {
//
//        self.title = title
//        self.isOn = isOn
//        self.callback = callback
//    }
//
    func makeUIView(context: Context) -> UISwitch {
        let checkbox = UISwitch()
        checkbox.preferredStyle = .checkbox
        
        checkbox.addTarget(context.coordinator,
                           action: #selector(Coordinator.handleToggle(sender:)),
                           for: .valueChanged)
        checkbox.backgroundColor = UIColor.clear
        
        return checkbox
    }
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = self.isOn
        uiView.title = self.title
        
        print("Update checkbox title: \(self.title)")
    }
    
    class Coordinator: NSObject {
       var control: CheckBox2

       init(_ control: CheckBox2) {
           self.control = control
       }

       @objc func handleToggle(sender: UISwitch) {
            self.control.isOn = sender.isOn
            self.control.callback(sender.isOn)
//        calendar.set(subscribed: sender.isOn)
       }
   }
}
