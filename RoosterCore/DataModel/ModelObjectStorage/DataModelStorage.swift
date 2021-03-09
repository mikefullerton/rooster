//
//  DataModelStorage.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation


/// Where we store the data we're interested in for our RCCalendarDataModel
public class DataModelStorage: Loggable {
    
    typealias DictionaryType = [String: CalendarItemStorageRecord]
    typealias FileType = JsonFile<DataModelStorageRecord>
    
    private var dataModelRecord: DataModelStorageRecord? = nil
    
    private let serialQueue = DispatchQueue(label: "rooster.data-model.queue")
    
    lazy private var storageFile: FileType = {
        let file = FileType(withURL: self.applicationSupportDirectory.appendingPathComponent("DataModel.json"))
        return file
    }()
    
    public func deleteStoredDataModel() {
        do {
            if self.storageFile.exists {
                try self.storageFile.delete()
                self.logger.log("deleted data model file: \(self.storageFile.url.path)")
            }
        } catch {
            self.logger.error("deleting data model file at path \(self.storageFile.url.path) failed with error: \(error.localizedDescription)")
        }
    }

    public private(set) var isLoaded: Bool = false
    
    public init() {
        self.logger.log("Created data model")
        self.logger.log("Storage file: \(self.storageFile.url.path)")
    }
    
    lazy var applicationSupportDirectory: URL = {
        let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        return applicationSupportDirectory.appendingPathComponent(bundleIdentifier)
    }()
    
    // MARK: calendars
    
    public func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return  (self.dataModelRecord?.calendars[calendarID]?.isSubscribed ?? false) ||
                (self.dataModelRecord?.delegateCalendars[calendarID]?.isSubscribed ?? false)
    }
    
    private func backgroundRead(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        do {
            var dataModelRecord = self.storageFile.exists ? try self.storageFile.read() : nil
            
            if dataModelRecord != nil && dataModelRecord?.version != DataModelStorageRecord.version {
                self.logger.log("loaded data model of version: \(dataModelRecord?.version ?? 0), expecting version: \(DataModelStorageRecord.version). Dropping data model.")
                dataModelRecord = nil
            }
            
            DispatchQueue.main.async {
                
                self.dataModelRecord = dataModelRecord
                self.isLoaded = true
                self.logger.log("read data model ok")
                completion(true, nil)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isLoaded = false
                self.logger.error("reading data model failed with error: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }
    
    public func read(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.logger.log("beginning datamodel read")
        
        self.serialQueue.async { [weak self] in
            self?.backgroundRead(completion: completion)
        }
    }
    
    private func pruneCalendarItems(_ calendarItems: [String: CalendarItemStorageRecord]) -> [String: CalendarItemStorageRecord] {
        var newItems: [String: CalendarItemStorageRecord] = [:]
        
        let today = Date()
        
        for (itemID, item) in calendarItems {
            if item.endDate.isEqualToOrAfterDate(today) || item.isRecurring {
                newItems[itemID] = item
            }
        }
        
        return newItems
    }
    
    public func prune() -> DataModelStorageRecord? {
        
        if var record = self.dataModelRecord {
            record.events = self.pruneCalendarItems(record.events)
            record.reminders = self.pruneCalendarItems(record.events)
            
            return record != self.dataModelRecord ? record: nil
        }

        return nil
    }
    
    // MARK: events

    
    public func reminderState(forKey key: String) -> CalendarItemStorageRecord? {
        return self.dataModelRecord?.reminders[key]
    }
    
    public func eventState(forKey key: String) -> CalendarItemStorageRecord? {
        return self.dataModelRecord?.events[key]
    }

    public func writeDateModel(_ dataModel: RCCalendarDataModel, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        // TODO: this is heavy handed, make it smarter
        
        self.logger.log("beginning write new data model")
                
        let record = dataModel.storageRecord
        
        guard record != self.dataModelRecord else {
            self.logger.log("stored data models are the same, not writing to disk")
            return
        }
        
        self.writeDataModelSync(record, completion: completion)
    }
    
    private func writeDataModelSync(_ dataModel: DataModelStorageRecord, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let file = self.storageFile

        do {
            try file.write(dataModel)
            
            Self.logger.log("sync write succeeded to file: \(file.url.path)")
            self.dataModelRecord = dataModel
            completion(true, nil)
            
        } catch {
            Self.logger.log("sync write failed to file: \(file.url.path), failed with error: \(error.localizedDescription)")
            completion(false, error)
        }
    }
    
    // not fully convinced this is working as expected, will circle back on it.
    private func writeDataModelAsync(_ dataModel: DataModelStorageRecord, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {

        let file = self.storageFile
        self.serialQueue.async {
            do {
                try file.write(dataModel)
                
                DispatchQueue.main.async {
                    Self.logger.log("write succeeded to file: \(file.url.path)")
                    self.dataModelRecord = dataModel
                    completion(true, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    Self.logger.log("write failed to file: \(file.url.path), failed with error: \(error.localizedDescription)")
                    completion(false, error)
                }
            }
        }
    }

}
