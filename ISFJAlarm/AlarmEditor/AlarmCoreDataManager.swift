//
//  AlarmCoreDataManager.swift
//  ISFJAlarm
//
//  Created by Jimin on 1/9/25.
//

import CoreData
import UIKit

class AlarmCoreDataManager {
    
    static let shared = AlarmCoreDataManager()
    private init() {}
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Create Alarm
    func createAlarm(time: Date, repeatDays: Set<Int>, label: String, sound: String, reminder: Bool) -> Alarm? {
        let alarm = Alarm(context: context)
        alarm.time = time
        alarm.repeatDays = (try? JSONEncoder().encode(Array(repeatDays))) ?? Data()
        alarm.label = label
        alarm.sound = sound
        alarm.reminder = reminder
        
        do {
            try context.save()
            print("Alarm successfully created!")
            return alarm
        } catch {
            print("Failed to create alarm: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch All Alarms
    func fetchAllAlarms() -> [Alarm] {
        let fetchRequest: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        
        do {
            let alarms = try context.fetch(fetchRequest)
            return alarms
        } catch {
            print("Failed to fetch alarms: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Specific Alarm
    func fetchAlarm(by identifier: NSManagedObjectID) -> Alarm? {
        do {
            guard let alarm = try context.existingObject(with: identifier) as? Alarm else {
                print("Failed to cast to Alarm")
                return nil
            }
            return alarm
        } catch {
            print("Failed to fetch alarm: \(error)")
            return nil
        }
    }
    
    // MARK: - Update Alarm
    func updateAlarm(_ alarm: Alarm, time: Date?, repeatDays: Set<Int>?, label: String?, sound: String?, reminder: Bool?) {
        if let time = time { alarm.time = time }
        if let repeatDays = repeatDays { alarm.repeatDays = (try? JSONEncoder().encode(Array(repeatDays))) ?? Data() }
        if let label = label { alarm.label = label }
        if let sound = sound { alarm.sound = sound }
        if let reminder = reminder { alarm.reminder = reminder }
        
        do {
            try context.save()
            print("Alarm successfully updated!")
        } catch {
            print("Failed to update alarm: \(error)")
        }
    }
    
    // MARK: - Delete Alarm
    func deleteAlarm(_ alarm: Alarm) {
        context.delete(alarm)
        
        do {
            try context.save()
            print("Alarm successfully deleted!")
        } catch {
            print("Failed to delete alarm: \(error)")
        }
    }
    
    // MARK: - Decode Repeat Days
    func decodeRepeatDays(from binaryData: Data?) -> Set<Int> {
        guard let binaryData = binaryData else { return [] }
        do {
            return try JSONDecoder().decode(Set<Int>.self, from: binaryData)
        } catch {
            print("Failed to decode repeatDays: \(error)")
            return []
        }
    }
}
