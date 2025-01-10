//
//  TimerCoreDataManager.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/8/25.
//

import CoreData

/// CoreData를 사용하여 타이머 데이터를 관리하는 싱글톤 클래스
class TimerCoreDataManager {
    /// 싱글톤 인스턴스
    static let shared = TimerCoreDataManager()
    
    /// 외부에서 인스턴스 생성을 막기 위한 private 생성자
    private init() {}
    
    /// CoreData 스택의 persistent container
    /// - container 초기화 및 persistent store 로드를 처리
    /// - 로드 실패 시 fatal error 발생
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Timer")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("코어 데이터 로드 실패: \(error)")
            }
        }
        return container
    }()
    
    /// 메인 context에 대한 접근자
    /// - Returns: viewContext (메인 스레드에서 사용되는 context)
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Context의 변경사항을 영구 저장소에 저장
    /// - 변경사항이 있을 경우에만 저장 시도
    /// - 저장 실패 시 에러를 출력
    func saveContext() {
        print("saveContext 호출됨")
        guard context.hasChanges else {
            print("저장할 변경사항 없음")
            return
        }
        do {
            try context.save()
            print("CoreData 저장 성공")
        } catch {
            print("저장 실패: \(error)")
        }
    }
    
    // MARK: - Timer CRUD Operations
    
    /// 새로운 타이머 항목을 생성하고 저장
    /// - Parameters:
    ///   - name: 타이머의 이름
    ///   - hours: 시간 (0-23)
    ///   - minutes: 분 (0-59)
    ///   - seconds: 초 (0-59)
    func saveTimer(name: String, hours: Int, minutes: Int, seconds: Int, selectedMusic: String?) {
        let timer = TimerItem(context: context)
        timer.name = name
        timer.hours = Int16(hours)
        timer.minutes = Int16(minutes)
        timer.seconds = Int16(seconds)
        timer.createdAt = Date()
        timer.selectedMusic = selectedMusic
        
        saveContext()
    }
    
    /// 저장된 모든 타이머 항목을 가져옴
    /// - Returns: 생성일 기준 내림차순으로 정렬된 타이머 배열
    /// - 실패 시 빈 배열 반환
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
    
    /// 특정 타이머 항목을 삭제
    /// - Parameter timer: 삭제할 타이머 객체
    func deleteTimer(_ timer: TimerItem) {
        do {
            context.delete(timer)
            try context.save()
            print("타이머 삭제 성공")
        } catch {
            print("타이머 삭제 실패: \(error)")
            // 실패 시 context 리셋
            context.rollback()
        }
    }
}
