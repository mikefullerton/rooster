//
//  TileImageView.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/21/21.
//

import Foundation
import Cocoa


open class TileImageView : AnimateableView {
    var image: NSImage
    
    let color:NSColor
    
    public init(withImage image: NSImage) {
        self.image = image
        self.color = NSColor.init(patternImage: image)
        super.init(frame: CGRect.zero)
        
        
        
//        self.sdkLayer.backgroundColor = color.cgColor
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawPatternImage(patternColor: NSColor, inRect:CGRect) {
        self.drawPatternImage(patternColor, inBezierPath: NSBezierPath(rect: inRect) )
    }

    func drawPatternImage(_ patternColor: NSColor, inBezierPath path: NSBezierPath) {

//        NSGraphicsContext.saveGraphicsState()
//
//        let yOffset = NSMaxY(self.convert(self.bounds, to:nil))
//        let xOffset = NSMinX(self.convert(self.bounds, to:nil))
//
//        NSGraphicsContext.current
////        setPatternPhase(CGPoint(x:xOffset, y:yOffset))
//
//        patternColor.set()
//
//        path.fill()
//
//        NSGraphicsContext.restoreGraphicsState()
//
////        [NSGraphicsContext restoreGraphicsState];

    }

    
    open override func draw(_ dirtyRect: NSRect) {
        self.color.setFill()
        
        dirtyRect.fill()
        
//        NSRect.fill(dirtyRect)

//        NSDrawThreePartImage(self.bounds,
//                             nil,
//                             self.image,
//                             nil,
//                             false,
//                             NSCompositingOperation.sourceOver,
//                             1.0,
//                             false)
    }

//    open override func draw(_ dirtyRect: NSRect) {
//        NSDrawThreePartImage(self.bounds,
//                             nil,
//                             self.image,
//                             nil,
//                             false,
//                             NSCompositingOperation.sourceOver,
//                             1.0,
//                             false)
//    }

//    override var intrinsicContentSize: NSSize {
//        let furthestFrame = frameForImageAtLogicalX(logicalX: columnCount-1, y: rowCount-1)
//        return NSSize(width: furthestFrame.maxX, height: furthestFrame.maxY)
//    }

    // MARK: - Drawing

//    func frameForImageAtLogicalX(logicalX: Int, y logicalY: Int) -> CGRect {
//        let spacing = 10
//        let width = 100
//        let height = 100
//        let x = (spacing + width) * logicalX
//        let y = (spacing + height) * logicalY
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
}

