//
//  CountDownCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class CountDownHeaderView: ListViewAdornmentView, CountDownTextFieldDelegate {
    private let scheduleUpdateHandler = ScheduleUpdateHandler()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addBlurView()
        self.addTitleView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public static func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 40)
    }

    lazy var blurView = BlurView()

    func addBlurView() {
        let view = self.blurView
        self.addSubview(view)
        view.activateFillInParentConstraints()
    }

    lazy var titleView: CountDownTextField = {
        let titleView = CountDownTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .center
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.smallSystemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        titleView.prefixString = "Your next alarm will fire in "
        titleView.showSecondsWithMinutes = 2.0

        return titleView
    }()

    func addTitleView() {
        let titleView = self.titleView

        self.addSubview(titleView)

        titleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override public func adornmentWillAppear(withContent content: Any?) {
        self.startTimer()
    }

    func startTimer() {
        if let fireDate = CoreControllers.shared.scheduleController.schedule.nextAlarmDate {
            self.titleView.startCountDown(withFireDate: fireDate)
        }
    }

    public func countDownDidFinish(_ countDownTextField: CountDownTextField) {
        self.scheduleUpdateHandler.handler = { _, _ in
            self.startTimer()
        }
        self.startTimer()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        self.titleView.stopCountDown()
        self.scheduleUpdateHandler.handler = nil
    }
}
