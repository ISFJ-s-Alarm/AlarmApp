//
//  AlertViewController.swift
//  ISFJAlarm
//
//  Created by Sol on 1/9/25.
//

import UIKit
import AVKit

protocol AlertViewControllerDelegate: AnyObject {
    func alertViewControllerDidDismiss()
    func alertViewControllerDidRequestSnooze(minutes: Int)
}

class AlertViewController: UIViewController {
    // MARK: - Properties
    private let alertView = AlertView() // AlertView 인스턴스 생성
    var player: AVPlayer? // 동영상 재생을 위한 AVPlayer
    private var timer: Timer? // 시간 업데이트 타이머
    private var snoozeTime = 5 // 다시 알림 시간 (기본값: 5분)
    var reminderEnabled: Bool = false // "다시 알림" 활성화 여부 전달
    var selectedSound: String? // 선택된 소리를 저장할 프로퍼티 추가
    private var audioPlayer: AVAudioPlayer? // 오디오 재생을 위한 플레이어 추가
    weak var delegate: AlertViewControllerDelegate?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupVideoBackground() // 배경 동영상 설정
        setupAlertView() // AlertView 추가
        startTimer() // 시간 업데이트 시작
        setupActions() // 버튼 액션 설정
        configureSnoozeButton() // 다시 알림 버튼 상태 설정
        playAlarmSound() // 알람 소리 재생 함수 호출
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate() // 화면이 사라질 때 타이머 종료
    }

    // MARK: - Private Methods
    private func setupAlertView() {
        view.addSubview(alertView)
        alertView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupVideoBackground() {
        guard let asset = NSDataAsset(name: "morning1") else {
            print("에셋에서 'morning1' 동영상을 찾을 수 없습니다.")
            return
        }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
        do {
            try asset.data.write(to: tempURL)
        } catch {
            print("동영상을 임시 파일로 저장하지 못했습니다: \(error)")
            return
        }
        player = AVPlayer(url: tempURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
    }

    private func setupActions() {
        alertView.snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)
        alertView.minusButton.addTarget(self, action: #selector(decreaseSnoozeTime), for: .touchUpInside)
        alertView.plusButton.addTarget(self, action: #selector(increaseSnoozeTime), for: .touchUpInside)
        alertView.dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)
    }

    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    /// "다시 알림" 버튼 상태 설정
    private func configureSnoozeButton() {
        alertView.snoozeButton.isHidden = !reminderEnabled
        alertView.minusButton.isHidden = !reminderEnabled
        alertView.plusButton.isHidden = !reminderEnabled
    }
    
    // 알람 소리 재생을 위한 새로운 함수
    private func playAlarmSound() {
        print("🎵 재생 시도할 소리: \(selectedSound ?? "없음")")
        
        guard let sound = selectedSound, sound != "무음" else {
            print("❌ 소리 없음 또는 무음 설정")
            return
        }
        
        // 오디오 세션 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ 오디오 세션 설정 성공")
        } catch {
            print("❌ 오디오 세션 설정 실패: \(error)")
        }

        // 알람 소리 파일 찾기
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3") {
            print("✅ 사운드 파일 찾음: \(soundURL)")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.volume = 1.0  // 볼륨을 최대로 설정
                audioPlayer?.numberOfLoops = -1  // 무한 반복
                audioPlayer?.prepareToPlay()  // 재생 준비
                let playSuccess = audioPlayer?.play() ?? false
                print("✅ 재생 시작 - 성공 여부: \(playSuccess)")
            } catch {
                print("❌ 오디오 플레이어 초기화 실패: \(error)")
            }
        } else {
            print("❌ 사운드 파일을 찾을 수 없음: \(sound)")
        }
    }

    // MARK: - @objc Methods
    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    @objc private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        alertView.timeLabel.text = formatter.string(from: Date())
    }
    
    
    // 다시 알림 시에도 소리 중지
    @objc private func snoozeAlarm() {
        print("⏰ 다시 알림 설정: \(snoozeTime)분")
        player?.pause()
        audioPlayer?.stop()
        print("🔊 오디오 플레이어 상태: \(audioPlayer?.isPlaying ?? false)")
        delegate?.alertViewControllerDidRequestSnooze(minutes: snoozeTime)
        dismiss(animated: true, completion: nil)
    }

    @objc private func decreaseSnoozeTime() {
        if snoozeTime > 1 {
            snoozeTime -= 5
            print("다시 알림 시간 감소: \(snoozeTime)분")
        }
    }

    @objc private func increaseSnoozeTime() {
        snoozeTime += 5
        print("다시 알림 시간 증가: \(snoozeTime)분")
    }
    
    // 알람 중지 시 소리도 함께 중지
    @objc private func stopAlarm() {
        print("🛑 알람 중지")
        player?.pause()
        audioPlayer?.stop()
        print("🔊 오디오 플레이어 상태: \(audioPlayer?.isPlaying ?? false)")
        delegate?.alertViewControllerDidDismiss()
        dismiss(animated: true, completion: nil)
    }
    
}
