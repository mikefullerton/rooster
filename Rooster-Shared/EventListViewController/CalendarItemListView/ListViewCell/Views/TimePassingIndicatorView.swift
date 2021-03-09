//
//  TimePassingIndicatorView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/5/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class TimePassingIndicatorView: SDKView {
    let height: CGFloat = 8

    let indicatorAlpha: CGFloat = 0.3

    override init(frame: NSRect) {
        super.init(frame: frame)

        self.sdkBackgroundColor = SDKColor.clear

        self.addBallView()
        self.addLineView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var lineView: SDKView = {
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.systemRed
        view.alphaValue = self.indicatorAlpha
        return view
    }()

    func addLineView() {
        let view = self.lineView

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.0),
            view.centerYAnchor.constraint(equalTo: self.ballView.centerYAnchor)
        ])
    }

    lazy var ballView: SDKView = {
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.systemRed
        view.sdkLayer.cornerRadius = self.height / 2
        //        view.sdkLayer.borderWidth = 1.0
        //        view.sdkLayer.borderColor = SDKColor.black.cgColor
        view.sdkLayer.masksToBounds = true
        //        view.alphaValue = self.indicatorAlpha
        return view
    }()

    func addBallView() {
        let view = self.ballView

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.heightAnchor.constraint(equalToConstant: self.height),
            view.widthAnchor.constraint(equalToConstant: self.height),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
