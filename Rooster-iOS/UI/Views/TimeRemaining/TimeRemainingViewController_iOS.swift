//
//  TimeRemainingViewController_iOS.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/23/20.
//

import Foundation
import UIKit

class TimeRemainingViewController_iOS: TimeRemainingViewController {
    let buttonSize: CGFloat = 26

    lazy var preferencesButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(handlePreferencesButtonClicked(_:)), for: .touchUpInside)

        view.setImage(UIImage(systemName: "gear"), for: .normal)

        view.frame = CGRect(x: 0, y: 0, width: self.buttonSize, height: self.buttonSize)
        view.contentHorizontalAlignment = .right
        view.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        view.setTitleColor(UIColor.systemGray, for: UIControl.State.highlighted)

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        return view
    }()

    lazy var calendarsButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(handlePreferencesButtonClicked(_:)), for: .touchUpInside)

        view.setImage(UIImage(systemName: "calendar"), for: .normal)

        view.frame = CGRect(x: 0, y: 0, width: self.buttonSize, height: self.buttonSize)
        view.contentHorizontalAlignment = .right
        view.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        view.setTitleColor(UIColor.systemGray, for: UIControl.State.highlighted)

        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        return view
    }()

    @objc func handlePreferencesButtonClicked(_ sender: UIButton) {
    }

    @objc func handleCalendarsButtonClicked(_ sender: UIButton) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = self.preferencesButton
        _ = self.calendarsButton
    }
}
