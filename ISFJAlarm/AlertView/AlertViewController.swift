//
//  AlertViewController.swift
//  ISFJAlarm
//
//  Created by Sol on 1/9/25.
//

import UIKit
import AVKit
import SnapKit
import Then

class AlertViewController: UIViewController {
    var player: AVPlayer?
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        $0.textAlignment = .center
    }
    private var timer: Timer?
    private let minusButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }
    private let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }
    private let snoozeButton = UIButton().then {
        $0.setTitle("다시 알림", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 25
    }
    private let dismissButton = UIButton().then {
        $0.setTitle("중단", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 15
    }

    private var snoozeTime = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupVideoBackground()
        setupUI()
        startTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    func setupVideoBackground() {
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

    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    func setupUI() {
        [timeLabel, minusButton, plusButton, snoozeButton, dismissButton].forEach { view.addSubview($0) }

        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
        }

        snoozeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(100)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }

        minusButton.snp.makeConstraints {
            $0.centerY.equalTo(snoozeButton)
            $0.trailing.equalTo(snoozeButton.snp.leading).offset(-20)
            $0.width.height.equalTo(50)
        }

        plusButton.snp.makeConstraints {
            $0.centerY.equalTo(snoozeButton)
            $0.leading.equalTo(snoozeButton.snp.trailing).offset(20)
            $0.width.height.equalTo(50)
        }

        dismissButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-40)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }

        snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decreaseSnoozeTime), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseSnoozeTime), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)
    }

    func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @objc func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timeLabel.text = formatter.string(from: Date())
    }

    @objc func snoozeAlarm() {
        print("\(snoozeTime)분 후 다시 알림이 설정되었습니다.")
    }

    @objc func decreaseSnoozeTime() {
        if snoozeTime > 1 {
            snoozeTime -= 5
            print("다시 알림 시간 감소: \(snoozeTime)분")
        }
    }

    @objc func increaseSnoozeTime() {
        snoozeTime += 5
        print("다시 알림 시간 증가: \(snoozeTime)분")
    }

    @objc func stopAlarm() {
        print("중단 버튼 클릭됨!")
        player?.pause()
        dismiss(animated: true, completion: nil) // AlertViewController를 닫음
    }
}
