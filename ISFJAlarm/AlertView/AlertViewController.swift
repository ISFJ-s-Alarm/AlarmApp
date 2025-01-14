//
//  AlertViewController.swift
//  ISFJAlarm
//
//  Created by Sol on 1/9/25.
//

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
}

/// 알람 화면을 담당하는 뷰 컨트롤러
class AlertViewController: UIViewController {
    // MARK: - Properties
    private let alertView = AlertView() // AlertView 인스턴스 생성
    var player: AVPlayer? // 동영상 재생을 위한 AVPlayer
    private var timer: Timer? // 시간 업데이트 타이머
    private var snoozeTime = 5 // 다시 알림 시간 (기본값: 5분)
    weak var delegate: AlertViewControllerDelegate?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupVideoBackground() // 배경 동영상 설정
        setupAlertView() // AlertView 추가
        startTimer() // 시간 업데이트 시작
        setupActions() // 버튼 액션 설정
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate() // 화면이 사라질 때 타이머 종료
    }

    // MARK: - Private Methods
    /// AlertView를 컨트롤러의 뷰에 추가
    private func setupAlertView() {
        view.addSubview(alertView)
        alertView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    /// 배경 동영상을 설정하고 반복 재생
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

    /// 버튼에 액션 연결
    private func setupActions() {
        alertView.snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)
        alertView.minusButton.addTarget(self, action: #selector(decreaseSnoozeTime), for: .touchUpInside)
        alertView.plusButton.addTarget(self, action: #selector(increaseSnoozeTime), for: .touchUpInside)
        alertView.dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)
    }

    /// 타이머 시작 및 시간 업데이트
    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    // MARK: - @objc Methods
    /// 동영상 반복 재생
    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    /// 현재 시간을 업데이트하여 라벨에 표시
    @objc private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        alertView.timeLabel.text = formatter.string(from: Date())
    }

    /// 다시 알림 버튼 클릭 시 동작
    @objc private func snoozeAlarm() {
        print("\(snoozeTime)분 후 다시 알림이 설정되었습니다.")
    }

    /// 마이너스 버튼 클릭 시 동작
    @objc private func decreaseSnoozeTime() {
        if snoozeTime > 1 {
            snoozeTime -= 5
            print("다시 알림 시간 감소: \(snoozeTime)분")
        }
    }

    /// 플러스 버튼 클릭 시 동작
    @objc private func increaseSnoozeTime() {
        snoozeTime += 5
        print("다시 알림 시간 증가: \(snoozeTime)분")
    }

    /// 알람 종료 버튼 클릭 시 동작
    @objc private func stopAlarm() {
        print("중단 버튼 클릭됨!")
        player?.pause()
        delegate?.alertViewControllerDidDismiss()  // 델리게이트 호출
        dismiss(animated: true, completion: nil)
    }
}
