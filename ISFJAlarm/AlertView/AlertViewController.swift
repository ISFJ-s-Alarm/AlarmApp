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
        view.backgroundColor = .black // 배경을 검은색으로 설정
        setupVideoBackground()
    }

    // 배경 동영상 설정 (에셋에서 불러오기)
    func setupVideoBackground() {
        // 에셋에서 동영상 데이터를 가져옵니다.
        guard let asset = NSDataAsset(name: "morning1") else {
            print("에셋에서 'morning' 동영상을 찾을 수 없습니다.")
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

        // 플레이어 레이어 추가
        DispatchQueue.main.async {
            self.view.layer.insertSublayer(playerLayer, at: 0)
            self.player?.play()
        }
    }
}
