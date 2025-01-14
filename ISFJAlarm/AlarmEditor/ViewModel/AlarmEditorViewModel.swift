//
//  ViewModel.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import Foundation

class AlarmEditorViewModel {
    
    private let coreDataManager = AlarmCoreDataManager.shared
    
    var isEditing: Bool {
        return existingAlarm != nil
    }
    
    var existingAlarm: Alarm?
    
    var updateUI: (() -> Void)?
    
    // 알람 데이터
    private var alarmTime: Date
    private var selectedDays: Set<Int>
    private var label: String
    private var sound: String
    var reminder: Bool
    
    init(alarm: Alarm? = nil) {
        if let alarm = alarm {
            self.existingAlarm = alarm
            self.alarmTime = alarm.time ?? Date()
            self.selectedDays = coreDataManager.decodeRepeatDays(from: alarm.repeatDays)
            self.label = alarm.label ?? "알람"
            self.sound = alarm.sound ?? "무음"
            self.reminder = alarm.reminder
        } else {
            self.alarmTime = Date()
            self.selectedDays = []
            self.label = "알람"
            self.sound = "무음"
            self.reminder = false
        }
    }
    
    func setTime(_ time: Date) {
        alarmTime = time
        updateUI?()
    }
    
    func getTime() -> Date {
        return alarmTime
    }
    
    // 반복 요일
    func setSelectedDays(_ days: [Int]) {
        selectedDays = Set(days)
        updateUI?()
    }
    
    func getSelectedDays() -> [Int] {
        return Array(selectedDays)
    }
    
    // 레이블
    func setLabel(_ newLabel: String) {
        label = newLabel
        updateUI?()
    }
    
    func getLabel() -> String {
        return label
    }
    
    // 사운드
    func setSound(_ newSound: String) {
        sound = newSound
        updateUI?()
    }
    
    func getSound() -> String {
        return sound
    }
    
    // 다시 알림
    func toggleReminder() {
        reminder.toggle()
        updateUI?()
    }
    
    func getReminderStatus() -> Bool {
        return reminder
    }
    
    // 알람 저장
    func saveAlarm() -> Bool {
        if let existingAlarm = existingAlarm {
            // 기존 알람 업데이트
            coreDataManager.updateAlarm(
                existingAlarm,
                time: alarmTime,
                repeatDays: selectedDays,
                label: label,
                sound: sound,
                reminder: reminder
            )
            return true
        } else {
            // 새 알람 생성
            let newAlarm = coreDataManager.createAlarm(
                time: alarmTime,
                repeatDays: selectedDays,
                label: label,
                sound: sound,
                reminder: reminder
            )
            return newAlarm != nil
        }
    }
    
    
}
