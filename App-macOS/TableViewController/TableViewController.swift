//
//  TableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import Cocoa

class TableViewController<ViewModel> : NSViewController,
                                       NSCollectionViewDataSource,
                                       NSCollectionViewDelegate,
                                       Reloadable where ViewModel: TableViewModelProtocol {
    
    private(set) var viewModel: ViewModel?
    
    var collectionView: NSCollectionView {
        return self.view as! NSCollectionView
    }
    
    func reloadViewModel() -> ViewModel? {
        return nil
    }
    
    // MARK: TableView
    
    public func reloadData() {
        self.viewModel = self.reloadViewModel()
        self.tableView.reloadData()
    }
    
    // MARK: UIViewController
    
    
    override func loadView() {
        let collectionView = self.collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.contentInset = NSEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear() {
        self.reloadData()
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        self.viewModel = nil
        self.collectionView.reloadData()
    }
    
    // MARK: Delegate
  
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, willDisplaySupplementaryView view: NSView, forElementKind elementKind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) {
        
    }

    
//    override func tableView(_ tableView: NSTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        guard let viewModel = self.viewModel,
//              let row = viewModel.row(forIndexPath: indexPath) else {
//            return 0
//        }
//
//        return row.height
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard let viewModel = self.viewModel,
//              let header = viewModel.header(forSection:section) else {
//            return 0
//        }
//        return header.height
//    }
//
//
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        guard let viewModel = self.viewModel,
//              let footer = viewModel.footer(forSection:section) else {
//            return 0
//        }
//        return footer.height
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> NSView? {
//        guard let viewModel = self.viewModel,
//              let header = viewModel.header(forSection:section) else {
//            return nil
//        }
//
//        return header.view
//    }
//
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> NSView? {
//        guard let viewModel = self.viewModel,
//              let footer = viewModel.footer(forSection:section) else {
//            return nil
//        }
//
//        return footer.view
//    }

    // MARK: Data Source
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
    }
    
//    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
//        
//        return nil
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let viewModel = self.viewModel,
//              let row = viewModel.row(forIndexPath: indexPath) else {
//            return UITableViewCell()
//        }
//
//        self.tableView.register(row.cellClass, forCellReuseIdentifier: row.cellReuseIdentifer)
//
//        if let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifer)  {
//            row.willDisplay(cell: cell,
//                            atIndexPath: indexPath,
//                            isSelected: tableView.indexPathForSelectedRow != nil ? tableView.indexPathForSelectedRow == indexPath : false)
//            return cell
//        }
//
//        return UITableViewCell()
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let viewModel = self.viewModel,
//              let tableSection = viewModel.section(forIndex: section) else {
//            return 0
//        }
//
//        return tableSection.rowCount
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return self.viewModel == nil ? 0 : viewModel!.sectionCount
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard let viewModel = self.viewModel,
//              let header = viewModel.header(forSection:section) else {
//            return nil
//        }
//
//        return header.title
//    }
//
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//
//        guard let viewModel = self.viewModel,
//              let footer = viewModel.footer(forSection:section) else {
//            return nil
//        }
//
//        return footer.title
//    }
}


