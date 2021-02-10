//
//  MouseTrackingCollectionViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

protocol MouseTrackingCollectionViewDelegate: AnyObject {
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseEnteredCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseMovedInCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseExitedCellAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDidEnterWithEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDidExitWithEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseDownAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent)
    
    func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                     mouseUpAtIndexPath indexPath: IndexPath,
                                     forItem item: NSCollectionViewItem,
                                     withEvent event: NSEvent)
}

class MouseTrackingCollectionView: NSCollectionView {
    
    var debugging: Bool {
        return false
    }
    
    weak var mouseTrackingDelegate: MouseTrackingCollectionViewDelegate?
    
    private var collectionViewTrackingAreas: [NSTrackingArea]?
    
    private var mouseInIndexPath: IndexPath?
    private var mouseInItem: NSCollectionViewItem?

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
                                     options: [ .mouseEnteredAndExited, .activeAlways, .enabledDuringMouseDrag ],
                                     owner: self,
                                     userInfo: nil))
        
        areas.append( NSTrackingArea(rect: self.frame,
                                     options: [ NSTrackingArea.Options.mouseMoved, .activeAlways, .enabledDuringMouseDrag ],
                                     owner: self,
                                     userInfo: nil))

        self.collectionViewTrackingAreas = areas
        areas.forEach { self.addTrackingArea($0) }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

//        if self.window != nil {
//            self.updateTrackingArea()
//        } else {
//            self.removeTrackingArea()
//        }
    }
    
    @objc func frameDidChange(_ notification: Notification) {
        self.updateTrackingArea()
    }
    
    private func mouseDidExit() {
        
        if let item = self.mouseInItem, let indexPath = self.mouseInIndexPath {
            if self.debugging {
                print("tracking: mouse exited: \(indexPath), \(Date().shortDateAndLongTimeString)")
            }

            self.mouseTrackingDelegate?.mouseTrackingCollectionView(self,
                                                                    mouseExitedCellAtIndexPath: indexPath,
                                                                    forItem: item)
            
            self.mouseInIndexPath = nil
            self.mouseInItem = nil
        }
    }
    
    func updateSelectedCell(with event: NSEvent) {

        let location = self.convert(event.locationInWindow, from: nil)
        
        if  let indexPath = self.indexPathForItem(at: location) {
            
            if let item = self.item(at: indexPath) {
                
                if item == self.mouseInItem && self.mouseInIndexPath == indexPath {
                    if self.debugging {
                        print("tracking: mouse moved: \(indexPath), \(Date().shortDateAndLongTimeString)")
                    }

                    self.mouseTrackingDelegate?.mouseTrackingCollectionView(self,
                                                                            mouseMovedInCellAtIndexPath: indexPath,
                                                                            forItem: item,
                                                                            withEvent: event)
                } else {
                    self.mouseDidExit()
                    self.mouseInItem = item
                    self.mouseInIndexPath = indexPath
                    
                    if self.debugging {
                        print("tracking: mouse entered: \(indexPath)")
                    }
                        
                    self.mouseTrackingDelegate?.mouseTrackingCollectionView(self,
                                                                            mouseEnteredCellAtIndexPath: indexPath,
                                                                            forItem: item,
                                                                            withEvent: event)
                }
            } else {
                if self.debugging {
                    print("tracking: failed to load item at index path: \(indexPath)")
                }
            }
        

        } else {
            self.mouseDidExit()
        }
    }
    
    override var acceptsFirstResponder: Bool {
        let accepts = super.acceptsFirstResponder
        print("tracking: accepts: \(accepts)")
        
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        
        let becameFirstResponder = super.becomeFirstResponder()
        print("tracking: becameFirstResponder: \(becameFirstResponder)")
        
        return becameFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        
        let resignedFirstResponder = super.becomeFirstResponder()
        print("tracking: resignedFirstResponder: \(resignedFirstResponder)")
        
        return resignedFirstResponder
    }


    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.updateSelectedCell(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.mouseDidExit()
    }

    override func mouseMoved(with event: NSEvent) {
//        print ("tracking: actual mouse moved: \(Date().shortDateAndLongTimeString)", Date())
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
        
        if  let indexPath = self.indexPathForItem(at: location){
            
            if let item = self.item(at: indexPath) {
                if self.debugging {
                    print("tracking: mouseDown")
                }
                self.mouseTrackingDelegate?.mouseTrackingCollectionView(self,
                                                                        mouseDownAtIndexPath: indexPath,
                                                                        forItem: item,
                                                                        withEvent: event)
            } else {
                if self.debugging {
                    print("tracking: failed to load item for mouseDown at index path: \(indexPath): \(self.indexPathsForVisibleItems())")
                }
            }

        } else {
            if self.debugging {
                print("tracking: mouseDown failed  to find collection view item")
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        
        let location = self.convert(event.locationInWindow, from: nil)
        
        if  let indexPath = self.indexPathForItem(at: location) {
            
            if let item = self.item(at: indexPath) {
                if self.debugging {
                    print("tracking: mouseUp")
                }
                
                self.mouseTrackingDelegate?.mouseTrackingCollectionView(self,
                                                                        mouseUpAtIndexPath: indexPath,
                                                                        forItem: item,
                                                                        withEvent: event)
            } else {
                if self.debugging {
                    print("tracking: failed to load item for mouseUp at index path: \(indexPath): \(self.indexPathsForVisibleItems())")
                }
            }
            
            
            
        } else {
            if self.debugging {
                print("tracking: mouseUp failed to find collection view item")
            }
        }
    }
    
//    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
//        print("tracking: firstMouse: \(event)")
//
//        return true
//    }

    
    
}
