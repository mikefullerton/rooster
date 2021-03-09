//
//  ScheduleController+Updating.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

extension ScheduleController {
/*
    public func update<T:ScheduleItem>(scheduleItems: [T]) {
        self.update(scheduleItems: scheduleItems, completion: nil)
    }

    public func update<T:ScheduleItem>(scheduleItems: [T],
                                       completion: ((_ success: Bool, _ items: [T]?, _ error: Error?) -> Void)?) {

        guard scheduleItems.count > 0 else {
            completion?(true, [], nil)
            return
        }

        let saver = EventKitCalendarItemBatchSaver(withItems: scheduleItems.map { $0.eventKitCalendarItem })
        saver.save { [weak self] success, savedItems, error in

            guard let self = self else { return }

            guard success else {
                self.logger.error("saving items failed with error: \(String(describing: error))")
                completion?(false, nil, error)
                return
            }

            guard let savedItems = savedItems else {
                self.logger.error("saved items were unexpected nil")
                completion?(false, nil, nil)
                return
            }

            guard savedItems.count == scheduleItems.count else {
                self.logger.error("saved items count is wrong, got \(savedItems.count), expecting: \(scheduleItems.count)")
                completion?(false, nil, nil)
                return
            }

            self.reload() { success, newSchedule, error in

                guard success else {
                    completion?(false, nil, error)
                    return
                }

                guard let newSchedule = newSchedule else {
                    completion?(false, nil, error)
                    return
                }

                var outItems:[T] = []
                for item in newSchedule.items {
                    if let index = scheduleItems.firstIndex(where: { $0.id == item.id }) {

                        if let updatedItem = newSchedule.items[index] as? T {
                            outItems.append(updatedItem)
                        } else {
                            self.logger.error("cast failed")
                        }

                    }
                }

                completion?(true, outItems, nil)
            }
        }
    }
*/
}
