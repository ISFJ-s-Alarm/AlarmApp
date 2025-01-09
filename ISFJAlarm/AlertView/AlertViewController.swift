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
        setupVideoBackground()
        setupDismissButton()
        setupSnoozeButton()
    }

    // 배경 동영상 설정 (에셋에서 불러오기)
    func setupVideoBackground() {
        // 에셋에서 동영상 데이터를 가져옵니다.
        guard let asset = NSDataAsset(name: "morning") else {
            print("에셋에서 동영상을 찾을 수 없습니다.")
            return
        }

        // 임시 디렉토리에 동영상을 저장합니다.
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
        do {
            try asset.data.write(to: tempURL)
        } catch {
            print("동영상 데이터를 임시 파일로 저장하는 데 실패했습니다: \(error)")
            return
        }

        // AVPlayer로 동영상 재생
        player = AVPlayer(url: tempURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        player?.play()

        // 동영상 반복 재생 설정
        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    // 알람 해제 버튼 설정
    func setupDismissButton() {
        let dismissButton = UIButton()
        dismissButton.setTitle("알람 끄기", for: .normal)
        dismissButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dismissButton.layer.cornerRadius = 10
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)

        view.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            dismissButton.widthAnchor.constraint(equalToConstant: 200),
            dismissButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func stopAlarm() {
        player?.pause()
        dismiss(animated: true, completion: nil)
    }

    // 스누즈 버튼 설정
    func setupSnoozeButton() {
        let snoozeButton = UIButton()
        snoozeButton.setTitle("스누즈", for: .normal)
        snoozeButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        snoozeButton.layer.cornerRadius = 10
        snoozeButton.translatesAutoresizingMaskIntoConstraints = false
        snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)

        view.addSubview(snoozeButton)

        NSLayoutConstraint.activate([
            snoozeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snoozeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            snoozeButton.widthAnchor.constraint(equalToConstant: 200),
            snoozeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func snoozeAlarm() {
        print("스누즈 기능 구현") // 여기에 실제 스누즈 로직 추가
        dismiss(animated: true, completion: nil)
    }
}
