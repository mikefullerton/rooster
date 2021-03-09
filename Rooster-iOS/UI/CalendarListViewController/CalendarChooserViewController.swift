//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

class CalendarChooserViewController: UIViewController, CalendarToolbarViewDelegate {
    let preferredWidth: CGFloat = 450

    lazy var calendarsViewController = PersonalCalendarListViewController()
    lazy var delegateCalendarsViewController = DelegateCalendarListViewController()

    private var calendarChooserView: CalendarChooserView {
        self.view as! CalendarChooserView
    }

    private func addViewController(_ controller: UIViewController) {
        self.addChild(controller)

        controller.view.isHidden = true

        self.view.addSubview(controller.view)

        controller.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        if let tableView = controller.view as? UITableView {
            tableView.contentInsetAdjustmentBehavior = .never

            let topHeight = self.calendarChooserView.topBar.intrinsicContentSize.height

            tableView.contentInset = UIEdgeInsets(top: topHeight,
                                                  left: 0,
                                                  bottom: self.calendarChooserView.bottomBar.intrinsicContentSize.height,
                                                  right: 0)

            tableView.contentOffset = CGPoint(x: 0, y: -topHeight)
        }

        self.view.invalidateIntrinsicContentSize()
    }

    override func loadView() {
        let view = CalendarChooserView()
        view.topBar.delegate = self

        self.view = view

        self.title = "Calendars"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addViewController(self.calendarsViewController)
        self.addViewController(self.delegateCalendarsViewController)

        self.calendarChooserView.bottomBar.doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
    }

    @objc func doneButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userClickCalendarsButton(self)
        self.preferredContentSize = self.calculatedSize
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    var calculatedSize: CGSize {
        var outSize = CGSize(width: self.preferredWidth, height: 0)
        outSize.height = self.view.intrinsicContentSize.height
        return outSize
    }

    @objc private func userClickCalendarsButton(_ sender: Any) {
        self.calendarsViewController.view.isHidden = false
        self.delegateCalendarsViewController.view.isHidden = true
        self.setToolbarItems(calendarColor: .link, delegateCalendarsColor: .label)
    }

    @objc private func userClickDelegateCalendarsButton(_ sender: Any) {
        self.calendarsViewController.view.isHidden = true
        self.delegateCalendarsViewController.view.isHidden = false
        self.setToolbarItems(calendarColor: .label, delegateCalendarsColor: .link)
    }

    func setToolbarItems(calendarColor: UIColor, delegateCalendarsColor: UIColor) {
        let calendarToolBarItem = UIBarButtonItem(title: "Calendars",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(userClickCalendarsButton(_:)))

        calendarToolBarItem.tintColor = calendarColor

        let delegateCalendarToolBarItem = UIBarButtonItem(title: "Delegate Calendars",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(userClickDelegateCalendarsButton(_:)))

        delegateCalendarToolBarItem.tintColor = delegateCalendarsColor
    }

    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int) {
        if index == 0 {
            self.userClickCalendarsButton(self)
        } else {
            self.userClickDelegateCalendarsButton(self)
        }
    }
}
