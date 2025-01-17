//
//  AlertView.swift
//  ISFJAlarm
//
//  Created by t2023-m105 on 1/13/25.
//

import UIKit
import SnapKit
import Then

/// 알람 화면의 UI를 담당하는 뷰
class AlertView: UIView {
    // 현재 시간 표시 라벨
    let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        $0.textAlignment = .center
    }

    // 마이너스 버튼 (시간 감소)
    let minusButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }

    // 플러스 버튼 (시간 증가)
    let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }

    // 다시 알림 버튼
    let snoozeButton = UIButton().then {
        $0.setTitle("다시 알림", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 25
    }
    
    // 현재 설정된 다시 알림 시간을 표시하는 라벨
    let snoozeTimeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
        $0.text = "5분" // 초기값 설정
        $0.isHidden = true // 초기에는 숨김 처리
    }

    // 알람 종료 버튼
    let dismissButton = UIButton().then {
        $0.setTitle("중단", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 15
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI() // UI 설정
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    /// UI 요소 배치 및 제약 조건 설정
    private func setupUI() {
        [timeLabel, minusButton, plusButton, snoozeButton, dismissButton, snoozeTimeLabel].forEach { addSubview($0) }

        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(130)
        }

        snoozeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(200)
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
        
        snoozeTimeLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(snoozeButton.snp.top).offset(-10) // 다시 알림 버튼 위에 배치
        }
    }
}
