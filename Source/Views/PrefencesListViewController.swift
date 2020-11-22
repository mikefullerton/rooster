//
//  PrefencesListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class PreferencesListViewController : UIViewController {

    private let calendars: CalendarListViewController = CalendarListViewController()
    private let delegateCalendars: CalendarListViewController = CalendarListViewController()
    
    private func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: DataModel.DidChangeEvent, object: nil)
        
        self.addChild(self.calendars)
        self.addChild(self.delegateCalendars)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override func loadView() {
        
        let lastView = UIView()
        lastView.setContentHuggingPriority(.defaultLow, for: .vertical)
        lastView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.calendars.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.delegateCalendars.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.delegateCalendars.view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.calendars.view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        let view = UIStackView(arrangedSubviews: [ self.calendars.view, self.delegateCalendars.view, lastView ])
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .fill
//        view.spacing = 0
        self.view = view
        
        
    }
    
    func updateViewControllers() {
        self.calendars.updateCalendars(DataModel.instance.calendars)
        self.calendars.view.sizeToFit()
//        print("\(self.calendars.view)")
        self.calendars.view.backgroundColor = UIColor.red
        
        self.delegateCalendars.updateCalendars(DataModel.instance.delegateCalendars)
        self.delegateCalendars.view.sizeToFit()
//        print("\(self.delegateCalendars.view)")
            
        self.delegateCalendars.view.backgroundColor = UIColor.green

        self.view.setNeedsLayout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewControllers()
    }

    @objc private func dataModelDidChange(_ notif: Notification) {
        self.updateViewControllers()
    }

}
