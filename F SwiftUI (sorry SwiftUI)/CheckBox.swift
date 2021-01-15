//
//  CheckBox.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import SwiftUI

struct CheckBoxContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = UISwitch
   
    var title: String
    @Binding var isOn: Bool
    var callback: (Bool) -> Void

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
       var control: CheckBoxContainer

       init(_ control: CheckBoxContainer) {
           self.control = control
       }

       @objc func handleToggle(sender: UISwitch) {
            self.control.isOn = sender.isOn
            self.control.callback(sender.isOn)
       }
   }
}

struct CheckBox: View {
    
    var title: String
    @Binding var isOn: Bool
    var callback: (Bool) -> Void
    
    var body: some View {
        CheckBoxContainer(title:self.title,
                          isOn: $isOn,
                          callback: self.callback).frame(width: 300, height: 26, alignment: .leading)
    }
    
    
    
}
