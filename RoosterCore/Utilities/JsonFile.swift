//
//  JsonFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/25/21.
//

import Foundation

open class JsonFile<T: Codable>: Loggable {
    public let url: URL
    public private(set) var schedulingQueue: DispatchQueue

    public init(withURL url: URL,
                schedulingQueue: DispatchQueue = DispatchQueue.global()) {
        self.schedulingQueue = schedulingQueue
        self.url = url
    }

    open func readSynchronously() throws -> T {
        let data = try Data(contentsOf: self.url)
        let decoder = JSONDecoder()
        let contents = try decoder.decode(T.self, from: data)
        return contents
    }

    open func writeSynchronously(_ item: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]

        let data = try encoder.encode(item)

        try data.write(to: self.url)
    }

    open func deleteSynchronously() throws {
        try FileManager.default.removeItem(at: self.url)
    }

    public func delete(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.schedulingQueue.async { [weak self] in
            guard let self = self else { return }

            do {
                if self.exists {
                    try self.deleteSynchronously()
                    self.logger.log("\(self.description) deleted ok at \(self.url.path)")
                } else {
                    self.logger.log("\(self.description) file not found on disk, not deleting at \(self.url.path)")
                }

                completion(true, nil)
            } catch {
                self.logger.error("\(self.description) failed to delete with error: \(String(describing: error)) at \(self.url.path)")
                completion(false, error)
            }
        }
    }

    public var exists: Bool {
        FileManager.default.fileExists(atPath: self.url.path)
    }

    public func read(completion: @escaping (_ success: Bool, _ readData: T?, _ error: Error?) -> Void) {
        self.schedulingQueue.async { [weak self] in
            guard let self = self else { return }

            do {
                let data = self.exists ? try self.readSynchronously() : nil
                self.logger.log("\(self.description) read data ok")

                completion(true, data, nil)
            } catch {
                self.logger.error("\(self.description) failed to read data with error: \(String(describing: error)) at \(self.url.path)")
                completion(false, nil, error)
            }
        }
    }

    public func write(_ data: T, completion: @escaping (_ success: Bool, _ writtenData: T?, _ error: Error?) -> Void) {
        self.schedulingQueue.async {[weak self] in
            guard let self = self else { return }

            do {
                try self.writeSynchronously(data)
                self.logger.log("\(self.description) wrote data ok at \(self.url.path)")

                completion(true, data, nil)
            } catch {
                self.logger.error("\(self.description) failed to write data with error: \(String(describing: error)) at \(self.url.path)")
                completion(false, data, error)
            }
        }
    }

    public func readOrCreate(defaultData: T, completion: @escaping (_ success: Bool, _ readData: T?, _ error: Error?) -> Void) {
        if self.exists {
            self.logger.log("read or create is reading, file exists at \(self.url.path)")
            self.read(completion: completion)
        } else {
            self.logger.log("read or create is writing, file does not exist at \(self.url.path)")
            self.write(defaultData, completion: completion)
        }
    }

    public var description: String {
        """
        \(type(of: self)): \
        url: \(self.url.path)
        """
    }
}
