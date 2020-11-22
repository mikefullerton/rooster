//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListViewController : UITableViewController {
    
    private var sortedGroups: [String] = []
    private var calendars: SourceToCalandarMap = [:] {
        didSet {
            self.sortedGroups = self.calendars.sortedKeys
        }
    }
    
    init() {
        super.init(style: .plain)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.register(CalendarListCell.self, forCellReuseIdentifier: CalendarListCell.reuseIdentifier)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CalendarListCell.reuseIdentifier) as? CalendarListCell,
           indexPath.section >= 0 && indexPath.section < self.sortedGroups.count{
            
            let key = self.sortedGroups[indexPath.section]
            
            if let calendars = self.calendars[key],
               indexPath.item >= 0 && indexPath.item < calendars.count {
                cell.setCalendar(calendars[indexPath.item])
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard section >= 0 && section < self.sortedGroups.count else {
            return 0
        }
        
        let key = self.sortedGroups[section]
        if let calendars = self.calendars[key] {
            return calendars.count
        }
        
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedGroups.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section >= 0 && section < self.sortedGroups.count else {
            return nil
        }

        return self.sortedGroups[section]
    }
    
    func updateCalendars(_ calendars: SourceToCalandarMap) {
        self.calendars = calendars
        self.tableView.reloadData()
        
//        var frame = self.view.frame
//        frame.size = self.tableView.contentSize
//        self.view.frame = frame
//        self.view.heightAnchor.constraint(equalToConstant: self.tableView.contentSize.height).isActive = true
//        self.view.widthAnchor.constraint(equalToConstant: self.tableView.contentSize.width).isActive = true
    }
}
