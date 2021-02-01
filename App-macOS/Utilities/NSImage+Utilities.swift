//
//  NSImage+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import Cocoa

func DrawImageInCGContext(_ size: CGSize, _ drawFunc: (_ context: CGContext) -> ()) -> NSImage? {
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    let width = Int(size.width)
    let height = Int(size.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 8
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    
    if let context = CGContext(data: nil,
                               width: width,
                               height: height,
                               bitsPerComponent: bitsPerComponent,
                               bytesPerRow: bytesPerRow,
                               space: colorSpace,
                               bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
    
        drawFunc(context)
        
        if let image = context.makeImage() {
            return NSImage(cgImage: image, size: size)
        }
    }
            
    return nil
}

func DrawImageInNSGraphicsContext(_ size: CGSize, _ drawFunc: ()->()) -> NSImage {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: NSColorSpaceName.calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0)
    
    let context = NSGraphicsContext(bitmapImageRep: rep!)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    
    drawFunc()
    
    NSGraphicsContext.restoreGraphicsState()
    
    let image = NSImage(size: size)
    image.addRepresentation(rep!)
    
    return image
}

    
extension NSImage {

    // this does not work for SF Symbols
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.isTemplate = true

        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceIn)
        image.unlockFocus()
        
        return image
    }
    
    // trying to work around not being able to tint SF Symbols
    func experimental_tint(color: NSColor) -> NSImage {
        let imageRect = NSRect(origin: NSZeroPoint, size: self.size)
        
        return DrawImageInNSGraphicsContext(self.size) {
//            self.lockFocus()
            color.set()
            self.draw(in: imageRect, from: imageRect, operation: .sourceIn, fraction: 1.0)
//            imageRect.fill(using: .sourceIn)
//            self.unlockFocus()
        }
        
        
        
//        if let cgContext = self.context(forSize: self.size) {
//            let gc = NSGraphicsContext(cgContext: cgContext, flipped: false)
//
//            let priorNsgc = NSGraphicsContext.current
//            defer { NSGraphicsContext.current = priorNsgc }
//            NSGraphicsContext.current = NSGraphicsContext(cgContext: gc, flipped: false)
//            nsImage.draw(in: imageRect)
//
//        }
//
//
////        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
//        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
//
//        [tintColor set];
//        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.size.width, self.size.height)] fillWithBlendMode:kCGBlendModeSourceIn alpha:1.0];
//
//        UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

        
//        return image
    }
    
    func context(forSize size: CGSize) -> CGContext? {
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 8
        let bytesPerRow = bytesPerPixel * width
        let rawData = malloc(height * bytesPerRow)
        let bitsPerComponent = 8
        if let context = CGContext(data: rawData,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
            return context
        }
        
        return nil
    }
}


//private func systemImage(named systemImageName: String, tint: SDKColor?) -> SDKImage? {
//    if let image = SDKImage(systemSymbolName: systemImageName, accessibilityDescription: self.toolTip),
//       let symbol = image.withSymbolConfiguration(SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)) {
//    
//        if tint != nil {
//            return symbol.tint(color: tint!)
//        }
//        
//        return symbol
//    }
//    
//    return nil
//}

