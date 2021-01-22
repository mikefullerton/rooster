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
                                       NSCollectionViewDelegateFlowLayout,
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
        self.collectionView.reloadData()
    }
    
    // MARK: UIViewController
    
    private func createLayout() -> NSCollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                             heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                              heightDimension: .absolute(20))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                         subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//
//        let layout = NSCollectionViewCompositionalLayout(section: section)

        let layout = NSCollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        return layout
    }
    
    override func loadView() {
        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = self.createLayout()
        
        
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
  
    func collectionView(_ collectionView: NSCollectionView,
                        willDisplay item: NSCollectionViewItem,
                        forRepresentedObjectAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        willDisplaySupplementaryView view: NSView,
                        forElementKind elementKind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) {
        
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return CGSize.zero
        }

        return CGSize(width: self.view.bounds.size.width, height: row.height)
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        insetForSectionAt section: Int) -> NSEdgeInsets {
        
        return NSEdgeInsets.zero
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            
            return NSSize.zero
        }
        
        return CGSize(width: self.view.bounds.size.width, height: header.height)
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> NSSize {
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection:section) else {

            return NSSize.zero
        }
        return CGSize(width: self.view.bounds.size.width, height: footer.height)
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    
    }
    
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
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }

        return tableSection.rowCount
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return NSCollectionViewItem()
        }
        let identifier = NSUserInterfaceItemIdentifier(rawValue: row.cellReuseIdentifer)
        self.collectionView.register(row.cellClass, forItemWithIdentifier:identifier)


        let item = self.collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        row.willDisplay(cell: item,
                        atIndexPath: indexPath,
                        isSelected:  false) // tableView.indexPathForSelectedRow != nil ? tableView.indexPathForSelectedRow == indexPath :
        return item
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return self.viewModel == nil ? 0 : viewModel!.sectionCount
    }
        
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


