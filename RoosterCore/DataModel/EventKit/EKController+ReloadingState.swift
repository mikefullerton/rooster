//
//  EKController+ReloadingState.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation

extension EKController {
    
    /// since loading status is asynchronous and a reload can be started at anytime, this encapsulates the state of the reloading so
    /// we don't overlap or needlessly reload.
    struct ReloadingState {
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
        
        var requestReload: ReloadingState {
            return ReloadingState(requestedCount: self.requestedCount + 1, reloading: self.reloading, requestID: self.requestID + 1)
        }

        var reloadingStarted: ReloadingState {
            return ReloadingState(requestedCount: 0, reloading: true, requestID: self.requestID + 1)
        }

        var reloadingFinished:ReloadingState {
            return ReloadingState(requestedCount: self.requestedCount, reloading: false, requestID: self.requestID + 1)
        }
        
        var description: String {
            return "\(type(of:self)): ID: \(self.requestID), requestedCount: \(self.requestedCount), reloading: \(self.reloading)"
        }

    }
}
