//
//  AlertViewController.swift
//  ISFJAlarm
//
//  Created by Sol on 1/9/25.
//

import UIKit
import AVKit

class AlertViewController: UIViewController {
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 동영상이 나오기 전 검정 배경 화면 설정
        setupVideoBackground()
        setupSnoozeButton()
        setupDismissButton()
    }

    // 배경 동영상 설정 (에셋에서 불러오기 + 반복 재생)
    func setupVideoBackground() {
        guard let asset = NSDataAsset(name: "morning1") else {
            print("에셋에서 'morning' 동영상을 찾을 수 없습니다.")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
        do {
            try asset.data.write(to: tempURL)
        } catch {
            print("동영상 데이터를 임시 파일로 저장하는 데 실패했습니다: \(error)")
            return
        }

        player = AVPlayer(url: tempURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        // 반복 재생 설정
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        player?.play()
    }

    // 동영상 반복 재생을 위한 메서드
    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    // "다시 알림" 버튼 추가!
    func setupSnoozeButton() {
        let snoozeButton = UIButton()
        snoozeButton.setTitle("다시 알림", for: .normal)
        snoozeButton.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        snoozeButton.setTitleColor(.white, for: .normal)
        snoozeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        snoozeButton.layer.cornerRadius = 25
        snoozeButton.translatesAutoresizingMaskIntoConstraints = false

        snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)

        view.addSubview(snoozeButton)

        NSLayoutConstraint.activate([
            snoozeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snoozeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 180), // 버튼 위치 조정
            snoozeButton.widthAnchor.constraint(equalToConstant: 150),
            snoozeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // "중단" 버튼 추가!
    func setupDismissButton() {
        let dismissButton = UIButton()
        dismissButton.setTitle("중단", for: .normal)
        dismissButton.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dismissButton.layer.cornerRadius = 15
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)

        view.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            dismissButton.widthAnchor.constraint(equalToConstant: 100),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // "다시 알림" 버튼 동작
    @objc func snoozeAlarm() {
        print("다시 알림 버튼 클릭됨!")
        dismiss(animated: true, completion: nil)
        // 여기에 스누즈 알람 설정 로직 추가 가능
    }

    // "중단" 버튼 동작
    @objc func stopAlarm() {
        print("중단 버튼 클릭됨!")
        player?.pause()

        // 반복 재생을 멈추기 위해 NotificationCenter에서 제거
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        dismiss(animated: true, completion: nil)
    }
}
