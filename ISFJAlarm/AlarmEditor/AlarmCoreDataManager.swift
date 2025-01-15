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
        // 코어데이터는 Set을 직접 저장할 수 없기 때문에 Data 타입으로 변환
        alarm.repeatDays = (try? JSONEncoder().encode(Array(repeatDays))) ?? Data()
        alarm.label = label
        alarm.sound = sound
        alarm.reminder = reminder
        alarm.isOn = true
        
        do {
            try context.save()
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
    func updateAlarm(_ alarm: Alarm, time: Date?, repeatDays: Set<Int>?, label: String?, sound: String?, reminder: Bool?, isOn: Bool?) {
        if let time = time { alarm.time = time }
        if let repeatDays = repeatDays { alarm.repeatDays = (try? JSONEncoder().encode(Array(repeatDays))) ?? Data() }
        if let label = label { alarm.label = label }
        if let sound = sound { alarm.sound = sound }
        if let reminder = reminder { alarm.reminder = reminder }
        if let isOn = isOn { alarm.isOn = isOn }
        
        do {
            try context.save()
        } catch {
            print("Failed to update alarm: \(error)")
        }
    }
    
    // MARK: - Delete Alarm
    func deleteAlarm(_ alarm: Alarm) {
        context.delete(alarm)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete alarm: \(error)")
        }
    }
    
    // MARK: - Decode Repeat Days
    // 코어데이터에 저장된 반복 요일 데이터를 다시 Set<Int>로 변환
    func decodeRepeatDays(from binaryData: Data?) -> Set<Int> {
        guard let binaryData = binaryData else { return [] }
        do {
            return try JSONDecoder().decode(Set<Int>.self, from: binaryData)
        } catch {
            print("Failed to decode repeatDays: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Alarms by Time Range (추가)
    func fetchAlarms(by timeRange: Date) -> [Alarm] {
        let fetchRequest: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "time == %@", timeRange as CVarArg)
        
        do {
            let alarms = try context.fetch(fetchRequest)
            return alarms
        } catch {
            print("Failed to fetch alarms by time range: \(error)")
            return []
        }
    }
}
