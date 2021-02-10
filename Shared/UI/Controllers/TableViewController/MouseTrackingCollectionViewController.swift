//
//  MouseTrackingCollectionViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

protocol MouseTrackingCollectionViewDelegate: AnyObject {
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseEnteredCellAtIndexPath indexPath: IndexPath, withEvent event: NSEvent)
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseMovedInCellAtIndexPath indexPath: IndexPath, withEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseExitedCellAtIndexPath indexPath: IndexPath)
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseDidEnterWithEvent event: NSEvent)
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseDidExitWithEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView, mouseDownAtIndexPath indexPath: IndexPath, withEvent event: NSEvent)
}

class MouseTrackingCollectionView: NSCollectionView {
    /// MARK: -- tracking area
    
    weak var mouseTrackingDelegate: MouseTrackingCollectionViewDelegate?
    
    private var collectionViewTrackingAreas: [NSTrackingArea]?
    
    private var mouseIn: [IndexPath] = []
    
    var trackingAreaEnabled: Bool = false {
        didSet {
            if self.trackingAreaEnabled {
                self.updateTrackingArea()
                self.postsFrameChangedNotifications = true
                NotificationCenter.default.addObserver(self, selector: #selector(frameDidChange(_:)), name: NSView.frameDidChangeNotification, object: self)

            } else {
                self.removeTrackingArea()
                self.postsFrameChangedNotifications = false
                NotificationCenter.default.removeObserver(self, name: NSView.frameDidChangeNotification, object: self)
            }
        }
    }
    
    private func removeTrackingArea() {
        
        if let trackingViewAreas = self.collectionViewTrackingAreas {
            trackingViewAreas.forEach { self.removeTrackingArea($0)}
            
            self.collectionViewTrackingAreas = nil
        }
       
    }
    
    private func updateTrackingArea() {
        
        self.removeTrackingArea()
       
        var areas:[NSTrackingArea] = []
        
        areas.append( NSTrackingArea(rect: self.frame,
                                     options: [ .mouseEnteredAndExited, .activeInKeyWindow, .enabledDuringMouseDrag ],
                                     owner: self,
                                     userInfo: nil))
        
        areas.append( NSTrackingArea(rect: self.frame,
                                     options: [ .mouseMoved, .activeInKeyWindow, .enabledDuringMouseDrag ],
                                     owner: self,
                                     userInfo: nil))

        self.collectionViewTrackingAreas = areas
        areas.forEach { self.addTrackingArea($0) }
    }
    
    @objc func frameDidChange(_ notification: Notification) {
        self.updateTrackingArea()
    }
    
    private func exitAll() {
        self.mouseIn.forEach {
            self.mouseTrackingDelegate?.mouseTrackingCollectionView(self, mouseExitedCellAtIndexPath: $0)
        }
        
        self.mouseIn = []
        
    }
    
    func updateSelectedCell(with event: NSEvent) {

        let location = self.convert(event.locationInWindow, from: nil)
        
        if  let indexPath = self.indexPathForItem(at: location) {
            if self.mouseIn.contains(indexPath) {
                self.mouseTrackingDelegate?.mouseTrackingCollectionView(self, mouseMovedInCellAtIndexPath: indexPath, withEvent: event)
            } else {
                self.mouseIn.append(indexPath)
                self.mouseTrackingDelegate?.mouseTrackingCollectionView(self, mouseEnteredCellAtIndexPath: indexPath, withEvent: event)
            }
        
            for mouseInIndexPath in self.mouseIn.reversed() {
                if mouseInIndexPath != indexPath {
                    if let index = self.mouseIn.firstIndex(of: mouseInIndexPath) {
                        self.mouseIn.remove(at: index)
                    }
                    self.mouseTrackingDelegate?.mouseTrackingCollectionView(self, mouseExitedCellAtIndexPath: mouseInIndexPath)
                }
            }

        } else {
            self.exitAll()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.updateSelectedCell(with: event)
    }
        
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.exitAll()
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.updateSelectedCell(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.updateSelectedCell(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let location = self.convert(event.locationInWindow, from: nil)
        
        if  let indexPath = self.indexPathForItem(at: location) {
            self.mouseTrackingDelegate?.mouseTrackingCollectionView(self, mouseDownAtIndexPath: indexPath, withEvent: event)
        }
    }
}
