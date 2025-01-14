//
//  TimerViewModel.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/9/25.
//

import Foundation
import Combine
import AVFoundation

import Foundation
import Combine
import AVFoundation

protocol TimerViewModelDelegate: AnyObject {
    func showAlertViewController()
}

class TimerViewModel {
    // Published properties
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var timerItems: [TimerModel] = []
    
    // Properties
    weak var delegate: TimerViewModelDelegate?
    private var timer: Timer?
    private let coreDataManager = TimerCoreDataManager.shared
    private var audioPlayer: AVAudioPlayer?
    private var selectedMusic: MusicModel?
    
    func setSelectedMusic(_ music: MusicModel) {
        selectedMusic = music
    }
    
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
        // CoreData에 한 번만 저장
        coreDataManager.saveTimer(
            name: name,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            selectedMusic: selectedMusic?.name
        )
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
            playTimerEndMusic()  // 타이머 종료 시 음악 재생 및 알람 화면 표시
        }
    }
    
    // 음악 재생 및 알람 화면 표시
    private func playTimerEndMusic() {
        guard let music = selectedMusic, music.name != "무음" else {
            // 음악이 없더라도 알람 화면은 표시
            delegate?.showAlertViewController()
            return
        }
        
        guard let path = Bundle.main.path(forResource: music.name, ofType: "mp3") else {
            print("음악 파일을 찾을 수 없습니다: \(music.name)")
            delegate?.showAlertViewController()
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // 음악 재생 후 알람 화면 표시
            delegate?.showAlertViewController()
        } catch {
            print("음악 재생 실패: \(error.localizedDescription)")
            delegate?.showAlertViewController()
        }
    }
    
    // MARK: - Data Operations
    func saveTimer(name: String) {
        coreDataManager.saveTimer(name: name, hours: hours, minutes: minutes, seconds: seconds, selectedMusic: nil)
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
        // 1. 먼저 CoreData에서 해당 타이머를 가져옴
        let timers = coreDataManager.fetchTimers()
        guard index < timers.count else { return }
        
        // 2. CoreData와 로컬 배열을 동시에 업데이트
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // CoreData에서 삭제
            self.coreDataManager.deleteTimer(timers[index])
            
            // 로컬 배열 업데이트 (배열 범위 체크 추가)
            if index < self.timerItems.count {
                self.timerItems.remove(at: index)
            }
            
            // UI 업데이트를 위해 Published 프로퍼티 갱신
            self.timerItems = self.timerItems
        }
    }
    
    // MARK: - Formatted Time
    var formattedTime: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension TimerViewModel {
    func stopTimerAndAudio() {
        stopTimer()
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
