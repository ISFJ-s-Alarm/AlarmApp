//
//  AlertViewController.swift
//  ISFJAlarm
//
//  Created by Sol on 1/9/25.
//

import UIKit
import AVKit

class AlertViewController: UIViewController {
    private let alertView = AlertView()
    var player: AVPlayer?
    private var timer: Timer?
    private var snoozeTime = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupVideoBackground()
        setupAlertView()
        startTimer()
        setupActions()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

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

    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @objc private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        alertView.timeLabel.text = formatter.string(from: Date())
    }

    @objc private func snoozeAlarm() {
        print("\(snoozeTime)분 후 다시 알림이 설정되었습니다.")
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

    @objc private func stopAlarm() {
        print("중단 버튼 클릭됨!")
        player?.pause()
        dismiss(animated: true, completion: nil)
    }
}
