//
//  EventKitItemTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import UIKit

class EventKitItemTableViewCell : UITableViewCell {
    
    public static let horizontalInset: CGFloat = 20
    public static let verticalInset: CGFloat = 10
    public static let labelHeight:CGFloat = 20
    public static let verticalPadding:CGFloat = 4

    var dividerView: DividerView
    var leftContentView : UIView?
    var rightContentView: UIView?
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        self.leftContentView = nil
        self.rightContentView = nil
        self.dividerView = DividerView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addDividerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLeftView(_ view: UIView) {
        self.contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate( [
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: EventListTableViewCell.verticalInset),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -EventListTableViewCell.verticalInset),

            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: EventListTableViewCell.horizontalInset),
//            view.trailingAnchor.constraint(equalTo: self.rightContentView!.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -EventListTableViewCell.horizontalInset),

            //            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        
        self.leftContentView = view
    }

    func addRightView(_ view: UIView) {
        self.contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: EventListTableViewCell.verticalInset),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -EventListTableViewCell.verticalInset),
            
            view.widthAnchor.constraint(equalToConstant: 250),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -EventListTableViewCell.horizontalInset),
        ])
        
        self.rightContentView = view
    }

    lazy var calendarColorBar: UIView = {
        let view = UIView()
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 6),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
        
        return view
    }()
    
    func addDividerView() {
        let dividerView = self.dividerView
        self.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dividerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        self.dividerView = dividerView
    }
    
    func updateCalendarBar(withCalendar calendar: EventKitCalendar) {
        if let calendarColor = calendar.color {
            self.calendarColorBar.isHidden = false
            self.calendarColorBar.backgroundColor = calendarColor
        } else {
            self.calendarColorBar.isHidden = true
        }

    }
}
