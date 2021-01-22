//
//  CalendarListCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import Cocoa

class CalendarListCell : NSCollectionViewItem, TableViewRowCell {
    
    typealias DataType = Calendar
    
    private var calendar: Calendar?

    private let padding:CGFloat = 8
    
    override func loadView() {
        self.view = NSView()
    }
    
    private lazy var checkBox: NSButton = {
        let view = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkBoxChecked(_:)))
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.calendarColorBar.trailingAnchor, constant: self.padding),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        return view
    }()
    
    lazy var calendarColorBar: NSView = {
        let view = NSView()
        
        
        self.view.addSubview(view)
      
        let width: CGFloat = 4
        let inset: CGFloat = 2
        
        view.wantsLayer = true
        view.layer?.cornerRadius = width / 2.0;
      
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -inset),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.padding),
        ])
        
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.calendar = nil
    }
    
    func configureCell(withData calendar: Calendar, indexPath: IndexPath, isSelected: Bool) {
        self.calendar = calendar
        self.checkBox.title = calendar.title
        self.checkBox.intValue = calendar.isSubscribed ? 1 : 0
        
        if let calendarColor = calendar.color {
            self.calendarColorBar.layer?.backgroundColor = calendarColor.cgColor
            self.calendarColorBar.isHidden = false
        } else {
            self.calendarColorBar.isHidden = true
        }
    }
    
    @objc func checkBoxChecked(_ checkbox: NSButton) {
        if let calendar = self.calendar {
            calendar.set(subscribed: !calendar.isSubscribed)
        }
    }
    
    static var cellHeight: CGFloat {
        return 28
    }
}
