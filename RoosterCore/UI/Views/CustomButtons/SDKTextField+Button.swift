//
//  ASDF.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/9/21.
//

import Foundation

extension SDKTextField {
    public convenience init(withButtonTitle title: String?,
                            attributedButtonTitle: NSAttributedString? = nil) {
        self.init()
        self.isEditable = false
        self.textColor = Theme(for: self).labelColor
        self.drawsBackground = false
        self.isBordered = false

        if let title = title {
            self.stringValue = title
        }

        if let attributedButtonTitle = attributedButtonTitle {
            self.attributedStringValue = attributedButtonTitle
        }
    }

    public convenience init(withAttributedButtonTitle attributedButtonTitle: NSAttributedString? = nil) {
        self.init(withButtonTitle: nil, attributedButtonTitle: attributedButtonTitle)
    }
}
