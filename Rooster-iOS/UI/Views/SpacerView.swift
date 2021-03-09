//
//  SpacerView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
import UIKit

public class SpacerView: ListViewAdornmentView<CGFloat> {
    public init() {
        super.init(frame: CGRect.zero)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class func preferredSize(forContent content: CGFloat?) -> CGSize {
        CGSize(width: -1, height: content ?? 0)
    }
}

