//
//  MenubarPopover+ContentView.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import SwiftUI

extension AppKitPlugin.MenuBarPopover {
    
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }


    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

}
