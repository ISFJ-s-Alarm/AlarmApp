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
    
    func startTimer(withName name: String) {
        guard !isRunning else { return }
        
        print("1. startTimer 시작")
        // 1. CoreData에 저장
        coreDataManager.saveTimer(name: name, hours: hours, minutes: minutes, seconds: seconds)
        print("2. CoreData 저장 완료")
        
        // 2. 즉시 타이머 목록 갱신
        loadTimers()
        print("3. loadTimers 호출 완료")
        
        // 3. 타이머 상태 변경 및 시작
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        print("4. 타이머 시작 완료")
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
        coreDataManager.saveTimer(name: name, hours: hours, minutes: minutes, seconds: seconds)
        loadTimers()
    }
    
    func loadTimers() {
        print("loadTimers 시작")
        let items = coreDataManager.fetchTimers()
        print("가져온 타이머 개수: \(items.count)")
        
        DispatchQueue.main.async { [weak self] in
            self?.timerItems = items.map { TimerModel.fromTimerItem($0) }
            print("timerItems 업데이트 완료: \(self?.timerItems.count ?? 0)개")
        }
    }
    
    func deleteTimer(at index: Int) {
        guard index < timerItems.count else { return }
        
        // CoreData에서 해당 항목 삭제
        let timers = coreDataManager.fetchTimers()
        guard index < timers.count else { return }
        
        // CoreData에서 삭제
        coreDataManager.deleteTimer(timers[index])
        
        // UI 업데이트
        loadTimers()  // 전체 목록 다시 로드
    }
    
    // MARK: - Formatted Time
    var formattedTime: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
