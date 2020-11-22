//
//  TableViewController+ViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

protocol TableViewSectionAdornmentProtocol {
    var view: UIView? { get }
    
    var height: CGFloat { get }
    
    var title: String? { get }
}

protocol TableViewRowProtocol {
    var cellReuseIdentifer: String { get }
    
    var cellClass: UITableViewCell.Type { get }
    
    var height: CGFloat { get }
    
    func willDisplay(cell: UITableViewCell)
}

protocol TableViewSectionProtocol {
    var rowCount: Int { get }
    
    func row(forIndex index: Int) -> TableViewRowProtocol?
    
    var header: TableViewSectionAdornmentProtocol? { get }
    
    var footer: TableViewSectionAdornmentProtocol? { get }
}

protocol TableViewModelProtocol {
    var sectionCount: Int { get }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol?
}

// MARK: Concrete View Model structs

struct TableViewModel : TableViewModelProtocol {
    private let sections: [TableViewSectionProtocol]

    init(withSections sections: [TableViewSectionProtocol] = []) {
        self.sections = sections
    }

    var sectionCount: Int {
        return self.sections.count
    }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0,
              index < self.sections.count else {
            return nil
        }
        return self.sections[index]
    }
}

struct TableViewSectionAdornment: TableViewSectionAdornmentProtocol {
    let view: UIView?
    let height: CGFloat
    let title: String?
    
    init(withView view: UIView,
         height: CGFloat) {
        
        self.view = view
        self.height = height
        self.title = nil
    }

    init(withTitle title: String,
         height: CGFloat) {
        
        self.view = nil
        self.height = height
        self.title = title
    }
    
    init(withHeight height: CGFloat) {
        self.view = UIView(frame: CGRect(x:0, y:0, width:0, height:height))
        self.height = height
        self.title = nil
    }
}

struct TableViewRow : TableViewRowProtocol {
    let title: String
    let height: CGFloat
    
    init(withTitle title: String,
         height: CGFloat = 26) {
        self.title = title
        self.height = height
    }
    
    var cellReuseIdentifer: String {
        return "TableViewRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return UITableViewCell.self
    }
    
    func willDisplay(cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}

struct TableViewSection : TableViewSectionProtocol {
    private let rows: [TableViewRowProtocol]
    
    let header: TableViewSectionAdornmentProtocol?
    
    let footer: TableViewSectionAdornmentProtocol?
    
    init(withRows rows:[TableViewRowProtocol],
         header: TableViewSectionAdornmentProtocol? = nil,
         footer: TableViewSectionAdornmentProtocol? = nil) {
        
        self.rows = rows
        self.header = header
        self.footer = footer
    }
    
    var rowCount: Int {
        return self.rows.count
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < 1 else {
            return nil
        }
            
        return self.rows[index]
    }
}

extension TableViewModelProtocol {
    func footer(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self[section]?.footer
    }
    
    func header(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self[section]?.header
    }
    
    func row(forSection section:Int, row: Int) -> TableViewRowProtocol? {
        if let section = self[section] {
           return section[row]
        }
        
        return nil
    }
    
    func row(forIndexPath indexPath: IndexPath) -> TableViewRowProtocol? {
        if let section = self[indexPath.section] {
            return section[indexPath.item]
        }
        
        return nil
    }

    subscript(index: Int) -> TableViewSectionProtocol? {
        get {
            return self.section(forIndex: index)
        }
    }
}

extension TableViewSectionProtocol {
    subscript(index: Int) -> TableViewRowProtocol? {
        get {
            return self.row(forIndex: index)
        }
    }
}
