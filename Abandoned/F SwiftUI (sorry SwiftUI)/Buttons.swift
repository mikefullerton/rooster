//
//  StandardButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import SwiftUI
import UIKit


//struct ButtonModifier : ViewModifier {
//    let kButtonWidth: CGFloat = 80.0
//    let kButtonHeight: CGFloat = 26.0
//
//    let buttonTextColor: Color
//
//    init() {
//        self.buttonTextColor = Color(UIColor.label)
//    }
//
//    init(withButtonTextColor buttonTextColor: Color) {
//        self.buttonTextColor = buttonTextColor
//    }
//
//    func body(content: Content) -> some View {
//            content
//                .frame(alignment: .center)
//                .foregroundColor(self.buttonTextColor)
//                .background(Color(UIColor.tertiarySystemFill))
//                .cornerRadius(6)
//                .buttonStyle(BorderlessButtonStyle())
//                .padding()
//        }
//}

struct GrayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(UIColor.white))
            .background(Color(UIColor.systemGray))
    }
}

struct ButtonDisplayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .frame(alignment: .center)
        .cornerRadius(6)
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct ButtonTextSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top:6, leading: 20, bottom: 6, trailing: 20))
    }
}

struct GrayButton: View {

    var title: String
    var callback:() -> Void

    var body: some View {
        Button(action: self.callback) {
            Text(self.title)
                .modifier(ButtonTextSizeModifier())
        }
        .modifier(GrayModifier())
        .modifier(ButtonDisplayModifier())
    }
}


struct GrayButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                GrayButton(title: "Hello mike") {
                    print("Hello")
                }
//                SystemButton(title: "Hello mike 2") {
//                    print("Hello")
//                }
            }

            
        }
        .background(Color.black)
    }
}
