//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

class LeftSideViewController : UIViewController {
    
    enum TabBarItem: Int, CaseIterable {
        case calendars, delegateCalendars
        
        func title() -> String {
            switch self {
            case .calendars:
                return "calendars"            case .delegateCalendars:
                return "delegate calendars"
            }
        }
        
    //    func image() -> UIImage? {
    //        switch self {
    //        case .all:
    //            return UIImage(systemName: "tray")
    //        case .favorites:
    //            return UIImage(systemName: "heart.circle")
    //        case .recents:
    //            return UIImage(systemName: "clock")
    //        case .collections:
    //            return UIImage(systemName: "folder")
    //        }
    //    }
    }

    let calendars: CalendarListViewController
    let delegateCalendars: DelegateCalendarListViewController
    
    let segmentedControl: UISegmentedControl
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.calendars = CalendarListViewController()
        self.delegateCalendars = DelegateCalendarListViewController()
        self.segmentedControl = UISegmentedControl()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        self.calendars = CalendarListViewController()
        self.delegateCalendars = DelegateCalendarListViewController()
        self.segmentedControl = UISegmentedControl()
        
        super.init(coder: coder)
    }
    
    func add(controller: UIViewController) {
        
        self.addChild(controller)
        
        controller.view.isHidden = true
        
        self.view.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.isMomentary = false

        weak var weakSelf = self
        
        let lhsAction = UIAction(title: "Calendars", image: nil, identifier: UIAction.Identifier(rawValue:"lhs")) { action in
            weakSelf?.calendars.view.isHidden = false
            weakSelf?.delegateCalendars.view.isHidden = true
            weakSelf?.segmentedControl.selectedSegmentIndex = 0
        }

        let rhsAction = UIAction(title: "Delegate Calendars", image: nil, identifier: UIAction.Identifier(rawValue:"rhs")) { action in
            weakSelf?.calendars.view.isHidden = true
            weakSelf?.delegateCalendars.view.isHidden = false
            weakSelf?.segmentedControl.selectedSegmentIndex = 1
        }

        self.segmentedControl.insertSegment(action: rhsAction, at: 0, animated: false)
        self.segmentedControl.insertSegment(action: lhsAction, at: 0, animated: false)
        self.segmentedControl.selectedSegmentIndex = 0
//        self.segmentedControl.apportionsSegmentWidthsByContent = true
        
        self.view.addSubview(self.segmentedControl)
        
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        let size = self.segmentedControl.sizeThatFits(CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude))
        
        NSLayoutConstraint.activate([
            self.segmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.segmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.segmentedControl.heightAnchor.constraint(equalToConstant: size.height),
            self.segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60)
        ])

        self.add(controller: self.calendars)
        self.add(controller: self.delegateCalendars)
        
        self.calendars.view.isHidden = false
    }
    
    
}
