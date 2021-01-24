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

    lazy var eventListViewController = EventListViewController()
    
    private var reloader: DataModelReloader? = nil
  
    let minimumContentSize = CGSize(width: 600, height: TimeRemainingViewController.preferredHeight)
    
    private var currentView: NSView?
    
    override func loadView() {
        let view = ContentAwareView(frame: CGRect.zero)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.view = view
        
        self.addNoMoreMeetingsView()
        
        self.reloader = DataModelReloader(for: self)
        
        self.addChild(self.eventListViewController)
    }
    
    lazy var noMoreMeetingsView: NSView = {
        let view = NSTextField()
        
        view.textColor = Theme(for: self.view).secondaryLabelColor
        view.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        view.isEditable = false
        view.isBordered = false
        view.drawsBackground = false
        view.stringValue = "No more meetings today! 🎉"
        view.alignment = .center
        
        return view
    }()
    
    func removeCurrentView() {
        if let currentView = self.currentView {
            currentView.removeFromSuperview()
            
            self.currentView = nil
        }
    }
    
    func addNoMoreMeetingsView() {
        let view = self.noMoreMeetingsView
        
        if self.currentView != view {
    
            self.removeCurrentView()
            
            self.view.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
                view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            ])
            
            self.currentView = view
        }
    }
    
    func addEventListView() {
        
        let view = self.eventListViewController.view
        
        if view != self.currentView {
            
            self.removeCurrentView()
        
            self.view.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            
            self.currentView = view
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.adjustWindowSize()
    }
    
    func adjustWindowSize() {
        DispatchQueue.main.async {
            var size = CGSize.zero

            if self.currentView == self.noMoreMeetingsView {
                size.height = self.noMoreMeetingsView.frame.size.height
            } else {
                size.height = self.eventListViewController.calculatedContentSize.height
            }

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
        if AppDelegate.instance.dataModelController.dataModel.allItems.count > 0 {
            self.addEventListView()
            self.adjustWindowSize()
        } else {
            self.addNoMoreMeetingsView()
        }
    }
}
