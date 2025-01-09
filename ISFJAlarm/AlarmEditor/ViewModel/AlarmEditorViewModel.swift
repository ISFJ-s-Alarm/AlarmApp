//
//  ViewModel.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import Foundation

class AlarmEditorViewModel {
    
    var updateUI: (() -> Void)?
    
    // 알람 데이터
    private var alarmTime: Date = Date()
    private var isRepeat: Bool = false
    private var label: String = ""
    private var sound: String = ""
    private var isReminder: Bool = false
    
    // 알람 저장
    func saveAlarm() {
        // 저장 로직
    }
    
    // 반복 설정 변경
    func toggleRepeat() {
        isRepeat.toggle()
        updateUI?()
    }
    
    // 레이블 변경
    func setLabel(_ newLabel: String) {
        label = newLabel
        updateUI?()
    }
    
    // 사운드 변경
    func setSound(_ newSound: String) {
        sound = newSound
        updateUI?()
    }
    
    // 다시 알림 설정
    func toggleReminder() {
        isReminder.toggle()
        updateUI?()
    }
}
