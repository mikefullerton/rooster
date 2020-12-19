//
//  DelegateDividerRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct DelegateDividerRow : TypedTableViewRowProtocol {
    
    typealias ViewClass = UITableViewCell
    
    private let title: String
    
    init(withTitle title: String) {
        self.title = title
    }
        
    var height: CGFloat {
        return 24
    }
    
    func willDisplay(cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}
