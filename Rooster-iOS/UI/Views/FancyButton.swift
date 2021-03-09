//
//  ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import UIKit

class FancyButton: UIButton {
    private var index: Int = 0

    override init(frame: CGRect) {
        self.contentViews = []
        super.init(frame: frame)
        self.contentHorizontalAlignment = .left
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var contentViews: [UIView] {
        didSet {
            self.contentViewIndex = 0
            self.invalidateIntrinsicContentSize()
        }
    }

    var contentViewIndex: Int {
        get {
            self.index
        }
        set(index) {
            guard index >= 0 && index < self.contentViews.count else {
                return
            }

            self.index = index

            let view = self.contentViews[index]

            self.setContentView(withView: view)
        }
    }

    var contentViewCount: Int {
        self.contentViews.count
    }

    private func setContentView(withView view: UIView) {
        if let imageView = view as? UIImageView {
            self.setTitle(nil, for: .normal)
            self.setImage(imageView.image, for: .normal)
            self.setPreferredSymbolConfiguration(imageView.preferredSymbolConfiguration, forImageIn: .normal)
            self.imageView?.tintColor = imageView.tintColor
        } else {
            self.setImage(nil, for: .normal)
        }

        if let label = view as? UILabel {
            self.setTitle(label.text, for: .normal)

//            if let titleLabel = self.titleColor(for: <#T##UIControl.State#>)

            self.setTitleColor(label.textColor, for: .normal)

//            self.titleLabel?.textColor = label.textColor
            self.titleLabel?.font = label.font
            self.titleLabel?.textAlignment = label.textAlignment
        }
    }

    override var intrinsicContentSize: CGSize {
        var maxAspectRatio: CGFloat = 0
        var maxSize = CGSize.zero

        for imageView in self.contentViews {
            let size = imageView.intrinsicContentSize

            let aspectRatio = size.width / size.height

            if maxAspectRatio < aspectRatio {
                maxAspectRatio = aspectRatio
            }

            if size.width > maxSize.width {
                maxSize.width = size.width
            }

            if size.height > maxSize.height {
                maxSize.height = size.height
            }
        }

        let outSize = CGSize(width: maxSize.height * maxAspectRatio,
                             height: maxSize.height)

        return outSize
    }
}
