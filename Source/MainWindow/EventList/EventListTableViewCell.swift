//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : UITableViewCell, TableViewRowCell, UITextViewDelegate {
    private var event: EventKitEvent? = nil
    private var leftView: LeftSideStack? = nil
    private var rightView: RightSideStack? = nil
    private var dividerView: DividerView? = nil
    
    public static let horizontalInset: CGFloat = 20
    public static let verticalInset: CGFloat = 10
    public static let labelHeight:CGFloat = 20
    public static let verticalPadding:CGFloat = 4

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addDividerView()
        self.addRightView()
        self.addLeftView()
    }
    
    func addLeftView() {
        let view = LeftSideStack()
        self.contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate( [
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: EventListTableViewCell.verticalInset),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -EventListTableViewCell.verticalInset),

            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: EventListTableViewCell.horizontalInset),
            view.trailingAnchor.constraint(equalTo: self.rightView!.leadingAnchor, constant: 0),

            //            view.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
       
        self.leftView = view
    }

    func addRightView() {
        let view = RightSideStack()
        self.contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: EventListTableViewCell.verticalInset),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -EventListTableViewCell.verticalInset),
            
            view.widthAnchor.constraint(equalToConstant: 250),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -EventListTableViewCell.horizontalInset),
        ])
        
        self.rightView = view
    }
    
    func addDividerView() {
        let dividerView = DividerView()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    override func prepareForReuse() {
        self.event = nil
    
        self.leftView?.prepareForReuse()
        self.rightView?.prepareForReuse()
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
    
    func setEvent(_ event: EventKitEvent) {

        self.event = event
        
        if let calendarColor = event.calendar.color {
            self.calendarColorBar.isHidden = false
            self.calendarColorBar.backgroundColor = calendarColor
        } else {
            self.calendarColorBar.isHidden = true
        }
        
        self.leftView?.setEvent(event)
        self.rightView?.setEvent(event)
        
        self.setNeedsLayout()
        
    }
}
