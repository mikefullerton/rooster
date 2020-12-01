//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : UITableViewCell, TableViewRowCell {
    private var event: EventKitEvent?
    private var stackedView: VerticalStackView?
    
    private static let horizontalInset: CGFloat = 20
    private static let labelHeight:CGFloat = 20
    private static let verticalPadding:CGFloat = 4

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.event = nil
        self.stackedView = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let views = [
            self.calendarTitleLabel,
            self.eventTitleLabel,
            self.timeLabel
          ]
        
        let stackView = VerticalStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0),
                                          views: views,
                                          padding:EventListTableViewCell.verticalPadding)
        self.contentView.addSubview(stackView)
        
        let size = stackView.sizeThatFits(CGSize(width:100, height:CGFloat.greatestFiniteMagnitude))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: size.height),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: EventListTableViewCell.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -EventListTableViewCell.horizontalInset),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        ])
        
        self.stackedView = stackView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3
    }
    
    override func prepareForReuse() {
        self.event = nil
    }
    
    @objc func handleButtonClick(_ sender: UIButton) {
        self.event?.stopAlarm()
    }
    
    func shortDateString(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        self.contentView.addSubview(label)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    lazy var eventTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        return label
    }()
    
    lazy var calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 100, height: EventListTableViewCell.labelHeight)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        button.setTitle("Stop", for: .normal)
        button.role = .destructive

        self.contentView.addSubview(button)

        button.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 20),
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
        ])
        
        return button
    }()
    
    func setEvent(_ event: EventKitEvent) {

        
        self.event = event
    
        self.button.isEnabled = event.isFiring
        
        let startTime = self.shortDateString(event.startDate)
        let endTime = self.shortDateString(event.endDate)
        
        self.timeLabel.text = "\(startTime) - \(endTime)"
        self.eventTitleLabel.text = event.title
        
        let calendar = event.calendar
      
        self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle)) "
    }
}
