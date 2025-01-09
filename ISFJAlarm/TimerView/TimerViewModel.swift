//
//  TimerViewModel.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/9/25.
//

import Foundation
import Combine

class TimerViewModel {
    // Published properties
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var timerItems: [TimerModel] = []
    
    // Private properties
    private var timer: Timer?
    private let coreDataManager = TimerCoreDataManager.shared
    
    // MARK: - Timer Operations
    func incrementHours() {
        hours = (hours + 1) % 24
    }
    
    func incrementMinutes() {
        minutes = (minutes + 1) % 60
    }
    
    func incrementSeconds() {
        seconds = (seconds + 1) % 60
    }
    
    func decrementHours() {
        hours = hours > 0 ? hours - 1 : 23
    }

    func decrementMinutes() {
        minutes = minutes > 0 ? minutes - 1 : 59
    }

    func decrementSeconds() {
        seconds = seconds > 0 ? seconds - 1 : 59
    }
    
    func startTimer() {
        guard timer == nil, (hours > 0 || minutes > 0 || seconds > 0) else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resetTimer() {
        stopTimer()
        hours = 0
        minutes = 0
        seconds = 0
    }
    
    func setTimer(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    private func updateTimer() {
        if seconds > 0 {
            seconds -= 1
        } else if minutes > 0 {
            minutes -= 1
            seconds = 59
        } else if hours > 0 {
            hours -= 1
            minutes = 59
            seconds = 59
        } else {
            stopTimer()
            // TODO: 타이머 종료 알림 추가
        }
    }
    
    
    
    // MARK: - Data Operations
    func saveTimer(name: String) {
        guard !name.isEmpty else { return }
        coreDataManager.saveTimer(name: name, hours: hours, minutes: minutes, seconds: seconds)
        loadTimers()
    }
    
    func loadTimers() {
        let items = coreDataManager.fetchTimers()
        timerItems = items.map { TimerModel.fromTimerItem($0) }
    }
    
    func deleteTimer(at index: Int) {
        guard index < timerItems.count else { return }
        // CoreData 삭제 로직 추가 필요
    }
    
    // MARK: - Formatted Time
    var formattedTime: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
