//
//  MainWindowViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation
import Cocoa

protocol MainWindowViewControllerDelegate : AnyObject {
    func mainWindowViewController(_ viewController: MainWindowViewController, preferredContentSizeDidChange size: CGSize)
}

class MainWindowViewController : NSViewController, DataModelAware {
    
    weak var delegate: MainWindowViewControllerDelegate?

    lazy var timeRemainingViewController = TimeRemainingViewController()

    lazy var eventListViewController = EventListViewController()
    
    private var reloader: DataModelReloader? = nil
  
    let minimumContentSize = CGSize(width: 600, height: TimeRemainingViewController.preferredHeight)
    
    func addTimeRemainingView() {

        let timeRemainingViewController = self.timeRemainingViewController

        self.addChild(timeRemainingViewController)

        self.view.addSubview(timeRemainingViewController.view)

        timeRemainingViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeRemainingViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            timeRemainingViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            timeRemainingViewController.view.heightAnchor.constraint(equalToConstant: TimeRemainingViewController.preferredHeight),
            timeRemainingViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        ])
    }
    
    override func loadView() {
        self.view = ContentAwareView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
        
        self.addTimeRemainingView()
        self.addEventListView()
        
        self.reloader = DataModelReloader(for: self)
        
        self.adjustWindowSize()
    }
    
    func addEventListView() {
        
        let eventListViewController = self.eventListViewController

        self.addChild(eventListViewController)

        self.view.addSubview(eventListViewController.view)

        eventListViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            eventListViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            eventListViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            eventListViewController.view.topAnchor.constraint(equalTo: self.timeRemainingViewController.view.bottomAnchor),
//            eventListViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            eventListViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        

    }
    
    func adjustScrollView() {
        if let scrollView = self.eventListViewController.collectionView.enclosingScrollView {
            
            scrollView.automaticallyAdjustsContentInsets = false
            
            scrollView.contentInsets = NSEdgeInsets(top: TimeRemainingViewController.preferredHeight,
                                                    left: 0,
                                                    bottom: 0,
                                                    right: 0)

            scrollView.contentView.automaticallyAdjustsContentInsets = false
            scrollView.contentView.scroll(to: CGPoint(x: 0, y: -TimeRemainingViewController.preferredHeight))
            
//            contentOffset = CGPoint(x: 0, y: -TimeRemainingViewController.preferredHeight)
        }

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
//        self.adjustScrollView()
        
        self.adjustWindowSize()
    }
    
    func adjustWindowSize() {
        DispatchQueue.main.async {
            var size = CGSize.zero
            
            size.height = self.timeRemainingViewController.view.frame.maxY
            
            size.height += self.eventListViewController.preferredContentSize.height
            
            self.preferredContentSize = self.adjustedSize(size)
        }
    }
    
    private func adjustedSize(_ size: CGSize) -> CGSize {
        return  CGSize(width: max(self.minimumContentSize.width, size.width),
                       height: max(self.minimumContentSize.height, size.height))
    }
    
    override var preferredContentSize: CGSize {
        get {
            return super.preferredContentSize
        }
        set(size) {
            print("Adjusting window size to: \(size)")
            
            super.preferredContentSize = size
            if let delegate = self.delegate {
                delegate.mainWindowViewController(self, preferredContentSizeDidChange: size)
            }
        }
    }

    func dataModelDidReload(_ dataModel: DataModel) {
        self.adjustWindowSize()
    }
}
