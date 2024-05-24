//
//  CoreAudio.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import AudioToolbox
import Cocoa
import Foundation
import AppKit

public class AudioDevices: Loggable {
    public init() {
    }

    public lazy var deviceCount: UInt32 = {
        var propertySize: UInt32 = 0

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("subDeviceCount: \(error)")
        }

        return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
    }()

    public lazy var allDevices: [AudioDevice] = {
        let devicesCount = self.deviceCount
        var devices = [AudioDeviceID](repeating: 0, count: Int(devicesCount))

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var devicesSize = devicesCount * UInt32(MemoryLayout<UInt32>.size)

        let error = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                               &propertyAddress,
                                               0,
                                               nil,
                                               &devicesSize,
                                               &devices)
        if error != 0 {
            self.logger.error("deviceName: \(error)")
        }

        return devices.map {
            AudioDevice(withID: $0)
        }
    }()

    public lazy var outputDevices: [AudioDevice] = {
        var result: [AudioDevice] = []

        for device in self.allDevices where device.isOutput {
            result.append(device)
        }

        return result
    }()

    public lazy var inputDevices: [AudioDevice] = {
        var result: [AudioDevice] = []
        for device in self.allDevices where device.isInput {
            result.append(device)
        }

        return result
    }()

    public static func setOutputDevice(withDeviceID newDeviceID: AudioDeviceID) {
        let propertySize = UInt32(MemoryLayout<UInt32>.size)
        var deviceID = newDeviceID

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                               &propertyAddress,
                                               0,
                                               nil,
                                               propertySize,
                                               &deviceID)
        if error != 0 {
            self.logger.error("setting default output device error: \(error)")
        }
    }

    public static func setInputDevice(withDeviceID newDeviceID: AudioDeviceID) {
        let propertySize = UInt32(MemoryLayout<UInt32>.size)
        var deviceID = newDeviceID

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultInputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                               &propertyAddress,
                                               0,
                                               nil,
                                               propertySize,
                                               &deviceID)
        if error != 0 {
            self.logger.error("setting default input device error: \(error)")
        }
    }

    static var defaultOutputDevice: AudioDevice {
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceID = kAudioDeviceUnknown

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                               &propertyAddress,
                                               0,
                                               nil,
                                               &propertySize,
                                               &deviceID)
        if error != 0 {
            self.logger.error("subDeviceCount: \(error)")
        }

        return AudioDevice(withID: deviceID)
    }

    static var defaultInputDevice: AudioDevice {
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var deviceID = kAudioDeviceUnknown

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                               &propertyAddress,
                                               0,
                                               nil,
                                               &propertySize,
                                               &deviceID)
        if error != 0 {
            self.logger.error("subDeviceCount: \(error)")
        }

        return AudioDevice(withID: deviceID)
    }
}

public class AudioDevice: Loggable, Identifiable, CustomStringConvertible {
    public typealias ID = AudioDeviceID

    public let id: AudioDeviceID

    public init(withID id: AudioDeviceID) {
        self.id = id
    }

    public lazy var deviceName: String = {
        var propertySize = UInt32(MemoryLayout<CFString>.size)

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var result: CFString = "" as CFString

        let error = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &result)
        if error != 0 {
            self.logger.error("error getting deviceName: \(error), for id: \(self.id)")
        }

        return result as String
    }()

    public var isInputActive: Bool {
        var foundActiveStream = false
        for stream in self.inputStreams where stream.isActive {
            foundActiveStream = true
            self.logger.log("Found active stream on device: \(self.id): \(self.deviceName)")
        }

        return foundActiveStream
    }

    public var isOutputActive: Bool {
        var foundActiveStream = false
        for stream in self.outputStreams where stream.isActive {
            foundActiveStream = true
            self.logger.log("Found active stream on device: \(self.id): \(self.deviceName)")
        }

        return foundActiveStream
    }

    public var outputStreams: [Stream] {
        var propertySize: UInt32 = 256

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(self.id, &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("data size error getting size of output stream: \(error)")
        }

        let streamCount = propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
        var streamIDs = [AudioStreamID](repeating: 0, count: Int(streamCount))

        let error2 = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &streamIDs)
        if error2 != 0 {
            self.logger.error("error getting output stream ids: \(error2)")
        }

        let streams = streamIDs.map { Stream(withID: $0) }

        return streams
    }

    public var inputStreams: [Stream] {
        var propertySize: UInt32 = 256

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeInput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(self.id, &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("error getting size of input streams: \(error)")
        }

        let streamCount = propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
        var streamIDs = [AudioStreamID](repeating: 0, count: Int(streamCount))

        let error2 = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &streamIDs)
        if error2 != 0 {
            self.logger.error("error getting input stream ids: \(error2)")
        }

        let streams = streamIDs.map { Stream(withID: $0) }

        return streams
    }

    lazy var isInput: Bool = {
        var propertySize: UInt32 = 256

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeInput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(self.id, &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("error getting size of input data: \(error)")
        }

        return propertySize > 0
    }()

    public lazy var isOutput: Bool = {
        var propertySize: UInt32 = 256

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyStreams),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(self.id, &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("error getting size of output data: \(error)")
        }

        return propertySize > 0
    }()

    /// if aggregate device
    public lazy var subDeviceList: [AudioDeviceID] = {
        let subDevicesCount = self.subDeviceCount
        var subDevices = [AudioDeviceID](repeating: 0, count: Int(subDevicesCount))

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        var subDevicesSize = subDevicesCount * UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &subDevicesSize, &subDevices)
        if status != 0 {
            self.logger.error("error getting subdevices list: \(status)")
        }

        return subDevices
    }()

    public lazy var subDeviceCount: UInt32 = {
        var propertySize: UInt32 = 0

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioAggregateDevicePropertyActiveSubDeviceList),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyDataSize(self.id, &propertyAddress, 0, nil, &propertySize)
        if error != 0 {
            self.logger.error("error getting count of sub devices: \(error)")
        }

        return propertySize / UInt32(MemoryLayout<AudioDeviceID>.size)
    }()

    public func setDeviceVolume(leftChannelLevel: Float,
                                rightChannelLevel: Float) {
        let channelsCount = 2
        var channels = [UInt32](repeating: 0, count: channelsCount)
        var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
        var leftLevel = leftChannelLevel
        var rightLevel = rightChannelLevel

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let status = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &channels)
        if status != 0 {
            self.logger.error("error setting output device volume, getting channels: \(status)")
        }

        if status != noErr { return }

        propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
        propertySize = UInt32(MemoryLayout<Float32>.size)
        propertyAddress.mElement = channels[0]

        let leftError = AudioObjectSetPropertyData(self.id, &propertyAddress, 0, nil, propertySize, &leftLevel)
        if leftError != 0 {
            self.logger.error("error setting output device volume, setting right level: \(leftError)")
        }

        propertyAddress.mElement = channels[1]

        let rightError = AudioObjectSetPropertyData(self.id, &propertyAddress, 0, nil, propertySize, &rightLevel)
        if rightError != 0 {
            self.logger.error("error setting output device volume, setting right level: \(rightError)")
        }
    }

    public var volume: (left: Float, right: Float) {
        let channelsCount = 2
        var channels = [UInt32](repeating: 0, count: channelsCount)
        var propertySize = UInt32(MemoryLayout<UInt32>.size * channelsCount)
        var leftLevel = Float32(-1)
        var rightLevel = Float32(-1)

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyPreferredChannelsForStereo),
            mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let status = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &channels)
        if status != 0 {
            self.logger.error("error volume getting channels: \(status)")
        }

        if status != noErr { return (left: -1, right: -1) }

        propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
        propertySize = UInt32(MemoryLayout<Float32>.size)
        propertyAddress.mElement = channels[0]

        let leftError = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &leftLevel)
        if leftError != 0 {
            self.logger.error("error getting left volume level: \(leftError)")
        }

        propertyAddress.mElement = channels[1]

        let rightError = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &rightLevel)
        if rightError != 0 {
            self.logger.error("error getting right volume level: \(rightError)")
        }

        return (left: leftLevel, right: rightLevel)
    }

    public lazy var transportType: AudioDevicePropertyID = {
        var deviceTransportType = AudioDevicePropertyID()
        var propertySize = UInt32(MemoryLayout<AudioDevicePropertyID>.size)

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioDevicePropertyTransportType),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

        let error = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &deviceTransportType)
        if error != 0 {
            self.logger.error("error count transport type: \(error)")
        }

        return deviceTransportType
    }()

    public lazy var isAggregateDevice: Bool = {
        self.transportType == kAudioDeviceTransportTypeAggregate
    }()

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        deviceName: \(self.deviceName), \
        transportType: \(self.transportType), \
        isAggregateDevice: \(self.isAggregateDevice), \
        isOutputDevice: \(self.isOutput), \
        inInputDevice: \(self.isInput),
        """
    }
}

extension AudioDevice {
    public class Stream: Identifiable, Loggable {
        public typealias ID = AudioStreamID

        public let id: AudioStreamID

        public init(withID id: AudioStreamID) {
            self.id = id
        }

        public var isActive: Bool {
            var propertySize: UInt32 = 4

            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: AudioObjectPropertySelector(kAudioStreamPropertyIsActive),
                mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

            var value: UInt32 = 0

            let error = AudioObjectGetPropertyData(self.id, &propertyAddress, 0, nil, &propertySize, &value)
            if error != 0 {
                self.logger.error("isActiveStream: \(error)")
            }

            return value == 1
        }
    }
}
