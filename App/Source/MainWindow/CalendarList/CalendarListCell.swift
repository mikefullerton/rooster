//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListCell : UITableViewCell, TableViewRowCell {
    
    typealias DataType = EventKitCalendar
    
    private var calendar: EventKitCalendar?

    private let padding:CGFloat = 8
    
    private lazy var checkBox: UISwitch = {
        let view = UISwitch()
        
        #if targetEnvironment(macCatalyst)
        view.preferredStyle = .checkbox
        #endif

        view.addTarget(self, action: #selector(checkBoxChecked(_:)), for: .valueChanged)
        self.contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        #if targetEnvironment(macCatalyst)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
        #else
        view.sizeToFit()
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        #endif
        
        
        return view
    }()
    
    #if os(iOS)
    private lazy var checkBoxTitleView : UILabel = {
        let view = UILabel()
        view.textColor = UIColor.secondaryLabel
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.checkBox.trailingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])

        return view
    }()
    #endif
    
    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.addSubview(view)
      
        let width: CGFloat = 4
        let inset: CGFloat = 2
        
        view.layer.cornerRadius = width / 2.0;
      
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.padding),
        ])
        
        return view
    }()
    
    override func prepareForReuse() {
        self.calendar = nil
    }
    
    #if targetEnvironment(macCatalyst)
    func setCheckBoxTitle(_ title: String) {
        self.checkBox.title = title
    }
    #else
    func setCheckBoxTitle(_ title: String) {
        self.checkBoxTitleView.text = title
    }
    #endif
    
    func configureCell(withData calendar: EventKitCalendar, indexPath: IndexPath, isSelected: Bool) {
        self.calendar = calendar
        self.setCheckBoxTitle(calendar.title)
        self.checkBox.setOn(calendar.isSubscribed, animated:false)
        self.checkBox.sizeToFit()
        if let calendarColor = calendar.color {
            self.calendarColorBar.backgroundColor = calendarColor
            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
    }
    
    @objc func checkBoxChecked(_ checkbox: UISwitch) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }
    
    static var cellHeight: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 28
        #else
        return 50
        #endif
    }
    
    
    
}
