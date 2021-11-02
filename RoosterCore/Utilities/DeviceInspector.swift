//
//  DeviceInspector.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/28/21.
//

import CoreMediaIO
import Foundation
import Quartz

public class DeviceInspector: Loggable {
    public init() {
    }

    public var hasBusyAudioInputDevices: Bool {
        var foundBusyAudioDevice = false

        let audioDevices = AudioDevices()

        for device in audioDevices.inputDevices {
            let isActive = device.isInputActive
            self.logger.log("device is active: \(device.description)")

            if isActive {
                foundBusyAudioDevice = true
            }
        }

        return foundBusyAudioDevice
    }

    // swiftlint:disable legacy_objc_type

    public var systemIsLockedOrAsleep: Bool {
        if let session = CGSessionCopyCurrentDictionary() as? [AnyHashable: Any?] {
            guard let isOnConsole = session["kCGSSessionOnConsoleKey"] as? NSNumber,
                    isOnConsole.intValue > 0 else {
                return true
            }

            if let isLocked = session["CGSSessionScreenIsLocked"] as? NSNumber {
                if isLocked.boolValue == true {
                    return true
                }
            }
        }

        return false
    }

    // swiftlint:enable legacy_objc_type

    // swiftlint:disable closure_body_length

    public lazy var coreMediaDeviceIDs: [CMIOObjectID] = {
        var opa = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
        )

        var (dataSize, dataUsed) = (UInt32(0), UInt32(0))
        var result = CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &opa, 0, nil, &dataSize)
        var devices: UnsafeMutableRawPointer?

        repeat {
            if devices != nil {
                free(devices!)
                devices = nil
            }
            devices = malloc(Int(dataSize))
            result = CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &opa, 0, nil, dataSize, &dataUsed, devices)
        } while result == OSStatus(kCMIOHardwareBadPropertySizeError)

        var outArray: [CMIOObjectID] = []

        if let devices = devices {
            for offset in stride(from: 0, to: dataSize, by: MemoryLayout<CMIOObjectID>.size) {
                let current = devices.advanced(by: Int(offset)).assumingMemoryBound(to: CMIOObjectID.self)
                // current.pointee is your object ID you will want to keep track of somehow

                outArray.append(current.pointee)
            }
        }
        if devices != nil {
            free(devices!)
        }

        return outArray
    }()

    // swiftlint:enable closure_body_length

    public var busyCoreMediaDevices: [CMIOObjectID] {
        var opa = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementWildcard)
        )

        var busy: [CMIOObjectID] = []

        for deviceID in self.coreMediaDeviceIDs {
            var (dataSize, dataUsed) = (UInt32(0), UInt32(0))
            var result = CMIOObjectGetPropertyDataSize(deviceID, &opa, 0, nil, &dataSize)
            if result == OSStatus(kCMIOHardwareNoError) {
                if let data = malloc(Int(dataSize)) {
                    result = CMIOObjectGetPropertyData(deviceID, &opa, 0, nil, dataSize, &dataUsed, data)
                    let onPtr = data.assumingMemoryBound(to: UInt8.self)

                    if onPtr.pointee != 0 {
                        busy.append(deviceID)
                    }

                    free(data )
                    // on.pointee != 0 means that it's in use somewhere, 0 means not in use anywhere
                }
            }
        }

        return busy
    }

    public var hasBusyCoreMediaDevices: Bool {
        !self.busyCoreMediaDevices.isEmpty
    }
}
