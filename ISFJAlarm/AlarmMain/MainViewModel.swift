//
//  MainAlarmModel.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/10/25.
//

import Foundation


class AlarmMainViewModel {
    
    var alarms: [Alarm] = []
    private let CoreData = AlarmCoreDataManager.shared
    
    var onDeleted: (() -> Void) = { }
    
    func deleteAlarm(at index: Int) {
        // 1. 먼저 CoreData에서 해당 타이머를 가져옴
        let alarms = CoreData.fetchAllAlarms()
        guard index < alarms.count else { return }
        
        // 2. CoreData와 로컬 배열을 동시에 업데이트
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // CoreData에서 삭제
            self.CoreData.deleteAlarm(alarms[index])
            
            // 로컬 배열 업데이트 (배열 범위 체크 추가)
            if index < self.alarms.count {
                self.alarms.remove(at: index)
            }
            
            // UI 업데이트를 위해 Published 프로퍼티 갱신
            self.alarms = self.alarms
            self.onDeleted()
        }
    }
}
