//
//  TableViewRowCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/2/21.
//

import Foundation

protocol TableViewRowCell {
    associatedtype ContentType

    static var viewHeight: CGFloat { get }

    func viewWillAppear(withData data: ContentType)
}
