//
//  LoadingView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/6/21.
//

import Foundation
import UIKit

class LoadingView: UIView {
    let loadingViewSize = CGSize(width: 600, height: 200)

    lazy var spinner = UIActivityIndicatorView(style: .large)

    init() {
        super.init(frame: CGRect.zero)
        self.addSpinner()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSpinner() {
        let spinner = self.spinner
        self.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false

        spinner.sizeToFit()

        let size = spinner.frame.size
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: size.width),
            spinner.heightAnchor.constraint(equalToConstant: size.height),
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        spinner.isHidden = false
        spinner.startAnimating()
    }

    override var intrinsicContentSize: CGSize {
        self.loadingViewSize
    }
}
