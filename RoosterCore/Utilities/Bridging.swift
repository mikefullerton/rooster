//
//  Bridging.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/5/21.
//

import Foundation

// from objects

public func bridge<T: AnyObject>(_ obj: T) -> UnsafeRawPointer {
    UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

public func bridgeMutable<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

public func bridgeRetained<T: AnyObject>(_ obj: T) -> UnsafeRawPointer {
    UnsafeRawPointer( Unmanaged.passRetained(obj).toOpaque())
}

public func bridgeTransfer<T: AnyObject>(_ ptr: UnsafeRawPointer) -> T {
    Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

// to objects

public func bridge<T: AnyObject>(_ ptr: UnsafeRawPointer) -> T {
    //    userData.assumingMemoryBound(to: AnyObject.self).pointee
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}
