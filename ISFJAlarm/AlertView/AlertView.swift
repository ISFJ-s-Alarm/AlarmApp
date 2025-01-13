//
//  AlertView.swift
//  ISFJAlarm
//
//  Created by t2023-m105 on 1/13/25.
//

import UIKit
import SnapKit
import Then

class AlertView: UIView {
    
    let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        $0.textAlignment = .center
    }
    let minusButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }
    let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 20
    }
    let snoozeButton = UIButton().then {
        $0.setTitle("다시 알림", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.layer.cornerRadius = 25
    }
    let dismissButton = UIButton().then {
        $0.setTitle("중단", for: .normal)
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 15
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        [timeLabel, minusButton, plusButton, snoozeButton, dismissButton].forEach { addSubview($0) }

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
    }
}
