//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import Cocoa

class CalendarChooserViewController : NSViewController, CalendarToolbarViewDelegate {
    let preferredWidth:CGFloat = 450

    lazy var calendarsViewController = CalendarListViewController()
    lazy var delegateCalendarsViewController = DelegateCalendarListViewController()

    private var calendarChooserView: CalendarChooserView {
        return self.view as! CalendarChooserView
    }
    
    private func addViewController(_ controller: NSViewController) {
        
        self.addChild(controller)
        
        
        controller.view.isHidden = true

        self.calendarChooserView.addContentView(controller.view)

        controller.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        if let collectionView = controller.view as? NSCollectionView,
           let scrollView = collectionView.enclosingScrollView {
            scrollView.automaticallyAdjustsContentInsets = false
            
            let topHeight = self.calendarChooserView.topBar.intrinsicContentSize.height
            
            scrollView.contentInsets = NSEdgeInsets(top: topHeight,
                                                  left: 0,
                                                  bottom: self.calendarChooserView.bottomBar.intrinsicContentSize.height,
                                                  right: 0)
            
            collectionView.scrollToItems(at: Set<IndexPath>([IndexPath(item: 0, section: 0)]), scrollPosition: .top)
        }
        
        self.view.invalidateIntrinsicContentSize()
    }
    
    override func loadView() {
        let view = CalendarChooserView()
        view.topBar.delegate = self
        
        self.view = view
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addViewController(self.calendarsViewController)
        self.addViewController(self.delegateCalendarsViewController)
        
        self.calendarChooserView.bottomBar.doneButton.target = self
        self.calendarChooserView.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))
    }

    @objc func doneButtonPressed(_ sender: NSButton) {
        self.view.window?.orderOut(self)
        NSApp.stopModal(withCode: .OK)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.calendarToolbarView(self.calendarChooserView.topBar, didChangeSelectedIndex: 0)
        self.preferredContentSize = self.calculatedSize
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    var calculatedSize: CGSize {
        var outSize = CGSize(width: self.preferredWidth, height: 0)
        outSize.height = self.view.intrinsicContentSize.height
        return outSize
    }
        
    func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int) {
        if index == 0 {
            self.calendarsViewController.view.isHidden = false
            self.delegateCalendarsViewController.view.isHidden = true
        } else {
            self.calendarsViewController.view.isHidden = true
            self.delegateCalendarsViewController.view.isHidden = false
        }
    }
    
    
    
}




