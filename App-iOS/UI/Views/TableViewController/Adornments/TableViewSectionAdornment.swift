//
//  TableViewSectionAdornment.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct TableViewSectionAdornment: TableViewSectionAdornmentProtocol {
    let view: UIView?
    let preferredHeight: CGFloat
    let title: String?
    
    init(withView view: UIView,
         height: CGFloat) {
        
        self.view = view
        self.preferredHeight = height
        self.title = nil
    }

    init(withTitle title: String,
         height: CGFloat) {
        
        self.view = nil
        self.preferredHeight = height
        self.title = title
    }
    
    init(withHeight height: CGFloat) {
        self.view = UIView(frame: CGRect(x:0, y:0, width:0, height:height))
        self.preferredHeight = height
        self.title = nil
    }
}
