//
//  ContentView.swift
//  Shared
//
//  Created by Mike Fullerton on 11/13/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
    
        
        Button("cluck") {
            CalendarManager.instance.playAlarmSound()
        }.padding()
        
        Button("quiet") {
            CalendarManager.instance.silenceAlarmSound()
        }.padding()
        
//        List(<#T##data: RandomAccessCollection##RandomAccessCollection#>, children: <#T##KeyPath<Identifiable, RandomAccessCollection?>#>, rowContent: <#T##(Identifiable) -> View#>)
    }
    
    func buildMenu(with builder: UIMenuBuilder) {
        print("hello")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
