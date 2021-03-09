//
//  EKDataModelReloader.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import EventKit

class EKControllerReloadScheduler: Loggable  {

    private var state: State {
        didSet {
            self.logger.log("state changed: \(self.state.description)")
        }
    }
    
    init() {
        self.state = State()
    }
    
    private func startReloadIfNeeded(forController controller: EKController,
                                     completion: @escaping (_ dataModel: RCCalendarDataModel) -> Void) {
        if !self.state.needsReload {
            self.logger.log("done reloading, ignoring request to reload")
        } else if self.state.canStartReload {
            self.logger.log("Actually starting reload")
            self.state = self.state.reloadingStarted
            self.actuallyReloadDataModel(forController: controller,
                                         completion: completion)
        } else {
            self.logger.log("defering reload request during reload")
        }
    }
    
    func requestReload(forController controller: EKController,
                       completion: @escaping (_ dataModel: RCCalendarDataModel) -> Void) {
        self.logger.log("requesting datamodel reload")
        
        DispatchQueue.main.async {
            self.state = self.state.requestReload
            self.startReloadIfNeeded(forController: controller,
                                     completion: completion)
        }
    }
    
    private func reloadIfNeeded(forController controller: EKController,
                                completion: @escaping (_ dataModel: RCCalendarDataModel) -> Void) {
        
        DispatchQueue.main.async {
            self.startReloadIfNeeded(forController: controller,
                                     completion: completion)
        }
    }
    
    private func actuallyReloadDataModel(forController controller: EKController,
                                         completion: @escaping (_ dataModel: RCCalendarDataModel) -> Void) {
    
        let startTime = Date.timeIntervalSinceReferenceDate
        
        self.logger.log("Fetching new data Model")
        controller.fetchNewDataModel() { (newDataModel) in
            
            let finishTime = Date.timeIntervalSinceReferenceDate
            self.logger.log("Finished loading new data Model in \(finishTime - startTime) seconds")
        
            completion(newDataModel)
        
            self.state = self.state.reloadingFinished
            
            self.reloadIfNeeded(forController: controller,
                                completion: completion)
        }
    }
}

extension EKControllerReloadScheduler {
    /// since loading status is asynchronous and a reload can be started at anytime, this encapsulates the state of the reloading so
    /// we don't overlap or needlessly reload.
    struct State {
        private var requestID: Int
        private(set) var requestedCount : Int
        private(set) var reloading: Bool
        
        init() {
            self.init(requestedCount: 0, reloading: false, requestID: 0)
        }
        
        private init(requestedCount: Int, reloading: Bool, requestID: Int) {
            self.requestedCount = requestedCount
            self.reloading = reloading
            self.requestID = requestID
        }
        
        var needsReload: Bool {
            return self.requestedCount > 0
        }
        
        var canStartReload: Bool {
            return self.requestedCount > 0 && !self.reloading
        }
        
        var requestReload: State {
            return State(requestedCount: self.requestedCount + 1, reloading: self.reloading, requestID: self.requestID + 1)
        }

        var reloadingStarted: State {
            return State(requestedCount: 0, reloading: true, requestID: self.requestID + 1)
        }

        var reloadingFinished:State {
            return State(requestedCount: self.requestedCount, reloading: false, requestID: self.requestID + 1)
        }
        
        var description: String {
            return "\(type(of:self)): ID: \(self.requestID), requestedCount: \(self.requestedCount), reloading: \(self.reloading)"
        }
    }
}
