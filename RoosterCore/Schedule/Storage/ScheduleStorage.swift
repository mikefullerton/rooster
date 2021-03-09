//
//  DataModelStorage.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

/// Where we store the data we're interested in for our EventKitDataModel
public class ScheduleStorage: Loggable {
    private(set) var storedScheduleData: ScheduleStorageRecord? {
        didSet { self.logger.log("updated stored schedule data") }
    }

    public private(set) var isLoaded = false
    private let schedulingQueue: DispatchQueue

    private lazy var url = FileManager.default.applicationSupportDirectory.appendingPathComponent("Schedule.json")

    private lazy var storageFile = JsonFile<ScheduleStorageRecord>(withURL: self.url, schedulingQueue: self.schedulingQueue)

    init(withSchedulingQueue schedulingQueue: DispatchQueue) {
        self.schedulingQueue = schedulingQueue

        self.logger.log("Created data model")
        self.logger.log("Storage file: \(self.storageFile.url.path)")
    }

    // MARK: - storage

    func read(completion: @escaping (_ success: Bool, _ storedData: ScheduleStorageRecord?, _ error: Error?) -> Void) {
        self.logger.log("beginning datamodel read")

        guard self.storageFile.exists else {
            self.logger.log("stored data doesn't exist, not attempting to read")
            completion(true, self.storedScheduleData, nil)
            return
        }

        self.storageFile.read { success, storedData, error in
            if success {
                assert(storedData != nil, "should not get nil data on successful read")

                self.storedScheduleData = storedData!
                self.isLoaded = true
                self.logger.log("read data model ok")
            } else {
                self.isLoaded = false
                self.logger.error("reading data model failed with error: \(String(describing: error))")
            }

            completion(success, storedData, error)
        }
    }

    func delete(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.storageFile.delete { success, error in
            if success {
                self.storedScheduleData = nil
                self.logger.log("deleted data model file: \(self.storageFile.url.path)")
            } else {
                self.logger.error("""
                    deleting data model file at path \(self.storageFile.url.path) failed with error: \(String(describing: error))
                    """)
            }

            completion(success, error)
        }
    }

    func writeScheduleDataIfNeeded(_ schedule: Schedule,
                                   completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let storedData = ScheduleStorageRecord(withSchedule: schedule)
        self.writeScheduleDataIfNeeded(storedData, completion: completion)
    }

    func writeScheduleDataIfNeeded(_ storedData: ScheduleStorageRecord,
                                   completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.logger.log("Saving data model")

        self.schedulingQueue.async { [weak self] in
            guard let self = self else { return }
            if storedData != self.storedScheduleData {
                do {
                    try self.storageFile.writeSynchronously(storedData)
                    self.storedScheduleData = storedData
                    self.logger.log("Updated schedule on disk ok")
                    completion(true, nil)
                } catch {
                    self.logger.error("Failed to update schedule on disk with error: \(String(describing: error))")
                    completion(false, error)
                }
            } else {
                self.logger.log("Schedule date hasn't changed, not writing")
                completion(true, nil)
            }
        }
    }

    public var exists: Bool {
        self.storageFile.exists
    }
}

extension ScheduleStorage {
//    private func pruneEventItems(_ calendarItems: [String: EventStorageRecord]) -> [String: EventStorageRecord] {
//        var newItems: [String: EventStorageRecord] = [:]
//
//        let today = Date()
//
//        for (itemID, item) in calendarItems {
//            if item.endDate.isEqualToOrAfterDate(today) || item.isRecurring {
//                newItems[itemID] = item
//            }
//        }
//
//        return newItems
//    }

    fileprivate func prune() -> ScheduleStorageRecord? {
        self.storedScheduleData

        // FIXME: pruned stored data

//        if var record = self.storedData {
//            record.events = self.pruneEventItems(record.events)
// //            record.reminders = self.pruneCalendarItems(record.events)
//
//            return record != self.storedData ? record: nil
//        }
//
//        return nil
    }

//    private func writeRecordSynchronously(_ record: StoredScheduleData,
//                                          completion: @escaping (_ success: Bool, _ storedData: StoredScheduleData?, _ error: Error?) -> Void) {
//
//        let file = self.storageFile
//
//        do {
//            try file.write(record)
//
//            Self.logger.log("synchronous write succeeded to file: \(file.url.path)")
//            completion(true, record, nil)
//
//        } catch {
//            Self.logger.log("synchronous write failed to file: \(file.url.path), failed with error: \(String(describing: error))")
//            completion(false, nil, error)
//        }
//    }

}
