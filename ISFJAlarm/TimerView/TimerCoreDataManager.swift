//
//  TimerCoreDataManager.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/8/25.
//


import CoreData

class TimerCoreDataManager {
    static let shared = TimerCoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Timer")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("코어 데이터 로드 실패: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("저장 실패: \(error)")
            }
        }
    }
    
    // MARK: - Timer CRUD Operations
    
    func saveTimer(name: String, hours: Int, minutes: Int, seconds: Int) {
        let timer = TimerItem(context: context)
        timer.name = name
        timer.hours = Int16(hours)
        timer.minutes = Int16(minutes)
        timer.seconds = Int16(seconds)
        timer.createdAt = Date()
        
        saveContext()
    }
    
    func fetchTimers() -> [TimerItem] {
        let request: NSFetchRequest<TimerItem> = TimerItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("타이머 가져오기 실패: \(error)")
            return []
        }
    }
    
    func deleteTimer(_ timer: TimerItem) {
        context.delete(timer)
        saveContext()
    }
}
