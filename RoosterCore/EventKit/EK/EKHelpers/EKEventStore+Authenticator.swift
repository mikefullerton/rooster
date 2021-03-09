//
//  EKStoreAuthenticator.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import EventKit
import Foundation

extension EKEventStore {
    struct Authenticator: Loggable {
        typealias CompletionBlock = (_ success: Bool, _ delegateEventStore: EKEventStore?, _ error: Error?) -> Void

        private func finishedRequestingAccessToEventStores(success: Bool,
                                                           delegateEventStore: EKEventStore?,
                                                           error: Error?,
                                                           completion: @escaping CompletionBlock) {
            DispatchQueue.main.async {
                if success {
                    if delegateEventStore != nil {
                        self.logger.log("did load delegateEventStore")
                    } else {
                        self.logger.log("delegate event store not loaded")
                    }

                    self.logger.log("finished requesting access to EventKit calendars with success")
                } else {
                    self.logger.error("failed to authenticate to event stores.)")
                }

                completion(success, delegateEventStore, error)
            }
        }

        #if os(macOS)
        private func requestAccessToDelegateStore(withUserStore store: EKEventStore,
                                                  completion: @escaping CompletionBlock) {
            let delegateEventStore = EKEventStore(sources: store.delegateSources)

            self.logger.log("requesting access to delegate calendars")

            self.requestAccess(toStore: delegateEventStore) { success, error in
                if success == false || error != nil {
                    self.logger.error("Failed to be granted access to delegate calendars with error: \(String(describing: error))")
                    completion(false, nil, error)
                } else {
                    self.logger.log("Access granted to delegate calendars")
                    completion(true, delegateEventStore, nil)
                }
            }
        }
        #else
        private func requestAccessToDelegateStore(withUserStore store: EKEventStore,
                                                  completion: @escaping CompletionBlock) {
            // sigh, can't get delegate calendars on iOS
            self.logger.log("Delegate eventStore not available on iOS")

            completion(true, nil, nil)
        }
        #endif

        private func fasterRequestAccess(toStore store: EKEventStore,
                                         completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            var count = 0
            var errorResults: [Error?] = [ nil, nil ]
            var successResults: [Bool] = [ false, false ]

            let completion = { (success: Bool, error: Error?) in
                count += 1

                if count == 1 {
                    successResults[0] = success
                    errorResults[0] = error
                } else {
                    successResults[1] = success
                    errorResults[1] = error

                    DispatchQueue.main.async {
                        completion(success, error)
                    }
                }
            }

            store.requestAccess(to: EKEntityType.event, completion: completion)
            store.requestAccess(to: EKEntityType.reminder, completion: completion)
        }

        private func requestAccess(toStore store: EKEventStore, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
            self.logger.log("requesting access to events in eventStore: \(store.eventStoreIdentifier)")
            store.requestAccess(to: EKEntityType.event) { success, error in
                if success {
                    self.logger.log("""
                        granted access to events in user eventStore, \
                        requesting access to reminders in eventStore: \(store.eventStoreIdentifier)
                        """)

                    store.requestAccess(to: EKEntityType.reminder) { success, error in
                        if success {
                            self.logger.log("granted access to reminders in eventStore: \(store.eventStoreIdentifier)")
                        }

                        DispatchQueue.main.async {
                            completion(success, error)
                        }
                    }
                } else {
                    self.logger.error("""
                        failed to be granted access to store: \(store.eventStoreIdentifier) with error: \(String(describing: error))
                        """)

                    DispatchQueue.main.async {
                        completion(success, error)
                    }
                }
            }
        }

        public func requestAccess(toEventStore eventStore: EKEventStore, completion: @escaping CompletionBlock) {
            self.logger.log("requesting access to events and reminders in user eventStore: \(eventStore.eventStoreIdentifier)")

            self.requestAccess(toStore: eventStore) { success, error in
                if success {
                    self.requestAccessToDelegateStore(withUserStore: eventStore) { success, delegateEventStore, error in
                        if !success || error != nil {
                            self.logger.error("""
                                failed to be granted access to delegate eventStore with error: \(String(describing: error))
                                """)
                        }

                        self.finishedRequestingAccessToEventStores(success: success,
                                                                   delegateEventStore: delegateEventStore,
                                                                   error: error,
                                                                   completion: completion)
                    }
                } else {
                    self.logger.error("""
                        failed to be granted access to user eventStore: \(eventStore.eventStoreIdentifier) \
                        with error: \(String(describing: error))
                        """)

                    self.finishedRequestingAccessToEventStores(success: success,
                                                               delegateEventStore: nil,
                                                               error: error,
                                                               completion: completion)
                }
            }
        }
    }
}
