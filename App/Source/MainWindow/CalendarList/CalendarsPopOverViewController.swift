//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

class CalendarsPopOverViewController : UIViewController {
  
    let popoverWidth:CGFloat = 400

    func add(controller: UIViewController) {
        
        self.addChild(controller)
        
        controller.view.isHidden = true
        
        self.view.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.calendarsToolbar.bottomAnchor, constant: 16),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
//    lazy var segmentedControl: UISegmentedControl = {
//
//        let segmentedControl = UISegmentedControl()
//        segmentedControl.isMomentary = false
//
//        weak var weakSelf = self
//
//        let lhsAction = UIAction(title: "Calendars", image: nil, identifier: UIAction.Identifier(rawValue:"lhs")) { action in
//            weakSelf?.calendars.view.isHidden = false
//            weakSelf?.delegateCalendars.view.isHidden = true
//            weakSelf?.segmentedControl.selectedSegmentIndex = 0
//        }
//
//        let rhsAction = UIAction(title: "Delegate Calendars", image: nil, identifier: UIAction.Identifier(rawValue:"rhs")) { action in
//            weakSelf?.calendars.view.isHidden = true
//            weakSelf?.delegateCalendars.view.isHidden = false
//            weakSelf?.segmentedControl.selectedSegmentIndex = 1
//        }
//
//        segmentedControl.insertSegment(action: rhsAction, at: 0, animated: false)
//        segmentedControl.insertSegment(action: lhsAction, at: 0, animated: false)
//        segmentedControl.selectedSegmentIndex = 0
////        segmentedControl.apportionsSegmentWidthsByContent = true
//
//        self.view.addSubview(segmentedControl)
//
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//
//        let size = segmentedControl.sizeThatFits(CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude))
//
//        NSLayoutConstraint.activate([
//            segmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//            segmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
//            segmentedControl.heightAnchor.constraint(equalToConstant: size.height),
//            segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20)
//        ])
//
//        return segmentedControl
//    }()
    
    lazy var calendars: CalendarListViewController = {
        return CalendarListViewController()
    }()
    
    lazy var delegateCalendars: DelegateCalendarListViewController = {
        return DelegateCalendarListViewController()
    }()
    
    func setToolbarItems(calendarColor: UIColor, delegateCalendarsColor: UIColor) {
        let calendarToolBarItem = UIBarButtonItem(title: "Calendars",
                                                  style: .plain,
                                                  target: self,
                                                  action:#selector(userClickCalendarsButton(_:)))
        
        calendarToolBarItem.tintColor = calendarColor
        
        let delegateCalendarToolBarItem = UIBarButtonItem(title: "Delegate Calendars",
                                                          style: .plain,
                                                          target: self,
                                                          action:#selector(userClickDelegateCalendarsButton(_:)))

        delegateCalendarToolBarItem.tintColor = delegateCalendarsColor

        self.calendarsToolbar.items = [ UIBarButtonItem.flexibleSpace(),
                                        calendarToolBarItem,
                                        delegateCalendarToolBarItem,
                                        UIBarButtonItem.flexibleSpace()]
        
    }
    
    @objc func userClickCalendarsButton(_ sender: Any) {
        self.calendars.view.isHidden = false
        self.delegateCalendars.view.isHidden = true

        self.setToolbarItems(calendarColor: .link, delegateCalendarsColor: .label)
    }

    @objc func userClickDelegateCalendarsButton(_ sender: Any) {
        self.calendars.view.isHidden = true
        self.delegateCalendars.view.isHidden = false

        self.setToolbarItems(calendarColor: .label, delegateCalendarsColor: .link)
    }

    lazy var calendarsToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        
        var appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        
            
        toolbar.standardAppearance = appearance
        
        
        
        let calendarToolBarItem = UIBarButtonItem(title: "Calendars",
                                                  style: .plain,
                                                  target: self,
                                                  action:#selector(userClickCalendarsButton(_:)))
        
        let delegateCalendarToolBarItem = UIBarButtonItem(title: "Delegate Calendars",
                                                          style: .plain,
                                                          target: self,
                                                          action:#selector(userClickDelegateCalendarsButton(_:)))

        toolbar.items = [ UIBarButtonItem.flexibleSpace(),
                          calendarToolBarItem,
                          UIBarButtonItem.flexibleSpace(),
                          delegateCalendarToolBarItem,
                          UIBarButtonItem.flexibleSpace()]

        
        self.view.addSubview(toolbar)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let size = toolbar.sizeThatFits(CGSize(width: self.popoverWidth,
                                               height: CGFloat.greatestFiniteMagnitude))
        
        #if targetEnvironment(macCatalyst)
        let topBuffer:CGFloat = 20
        #else
        let topBuffer:CGFloat = 100
        #endif
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            toolbar.heightAnchor.constraint(equalToConstant: size.height),
            toolbar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topBuffer)
            
        ])

        return toolbar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = self.calendarsToolbar
        
        self.add(controller: self.calendars)
        self.add(controller: self.delegateCalendars)
        
        self.userClickCalendarsButton(self)
    }
    
    var calculatedSize: CGSize {
        
        // TODO: Caculate height of largest list of calendars
        
        return CGSize(width: self.popoverWidth, height: 700)
    }
}
