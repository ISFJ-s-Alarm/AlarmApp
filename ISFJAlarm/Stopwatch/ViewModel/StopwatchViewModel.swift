//
//  StopwatchViewModel.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/10/25.
//

import Foundation
import Combine

/// 스톱워치의 상태와 동작을 관리하는 뷰모델
class StopwatchViewModel {
    @Published var timerText: String = "00:00.00" // 현재 시간 텍스트
    @Published var laps: [StopwatchLap] = [] // 랩 데이터 배열

    private var timer: Timer? // 스톱워치 타이머
    private var startTime: Date? // 타이머 시작 시간
    private var elapsedTime: TimeInterval = 0 // 경과 시간
    private var isRunning: Bool = false // 타이머 실행 여부
    private var lapStartTime: Date? // 랩 시작 시간
    private var totalLapTime: TimeInterval = 0 // 전체 랩 누적 시간

    /// 시작/정지 버튼 동작
    func startStopTimer() {
        isRunning ? stopTimer() : startTimer()
    }

    /// 리셋 버튼 동작
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        totalLapTime = 0
        laps.removeAll()
        timerText = "00:00.00"
    }

    /// 랩 기록 버튼 동작
    func recordLap() {
        guard isRunning, let lapStartTime = lapStartTime else { return }

        let lapTime = Date().timeIntervalSince(lapStartTime)
        totalLapTime += lapTime
        self.lapStartTime = Date()

        let lap = StopwatchLap(
            lapNumber: laps.count + 1,
            lapTime: formatTime(lapTime),
            totalTime: formatTime(totalLapTime)
        )
        laps.insert(lap, at: 0) // 가장 최근 랩을 상단에 추가
    }

    /// 타이머 시작
    private func startTimer() {
        isRunning = true
        startTime = Date() - elapsedTime // 정지 후 이어서 시작
        lapStartTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
            self.timerText = self.formatTime(self.elapsedTime)
        }
    }

    /// 타이머 정지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    /// 시간을 포맷팅하여 문자열로 변환
    /// - Parameter time: 경과 시간
    /// - Returns: 포맷팅된 시간 문자열
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((time * 100).truncatingRemainder(dividingBy: 100))
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
