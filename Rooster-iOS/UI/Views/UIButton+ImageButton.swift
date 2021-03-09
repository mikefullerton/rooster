//
//  UIButton+ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

extension UIButton {
    static func createImageButton(withImage image: UIImage?) -> UIButton {
        let view = UIButton(type: .custom)

        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        view.setImage(image, for: .normal)

        view.contentHorizontalAlignment = .center
        view.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        view.setTitleColor(UIColor.systemGray, for: UIControl.State.highlighted)
//        view.frame = CGRect(x: 0, y: 0, width: self.buttonSize, height: self.buttonSize)

        return view
    }
}

class CustomButton: UIButton {
    var preferredSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = self.preferredSize.width
        size.height = self.preferredSize.height
        return size
    }
}
