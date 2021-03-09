//
//  DividerView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/30/20.
//

import Foundation
import UIKit

class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let view = UIView()
        view.backgroundColor = Theme(for: view).borderColor

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        let indent: CGFloat = 0

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(indent * 2)),
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: indent),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: indent),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

