//
//  StopwatchView.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/10/25.
//

import UIKit
import SnapKit

/// 스톱워치 화면 뷰
class StopwatchView: UIView {
    let timerLabel = UILabel()       // 타이머 표시 레이블
    let lapButton = UIButton()       // 랩 버튼
    let resetButton = UIButton()     // 리셋 버튼
    let startStopButton = UIButton() // 시작/정지 버튼
    let tableView = UITableView()    // 랩 기록 표시 테이블
    let headerView = UIView()        // 테이블 헤더
    let lapLabel = UILabel()         // 헤더의 랩 레이블
    let lapTimeLabel = UILabel()     // 헤더의 랩 타임 레이블
    let totalTimeLabel = UILabel()   // 헤더의 전체 시간 레이블

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UI 구성 메서드
    private func setupUI() {
        backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)

        // 타이머 레이블 설정
        timerLabel.text = "00:00.00"
        timerLabel.font = .systemFont(ofSize: 80, weight: .regular)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center

        // 버튼 구성
        configureButton(resetButton, title: "리셋", color: UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1))
        configureButton(startStopButton, title: "시작", color: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1))
        configureButton(lapButton, title: "랩", color: UIColor(red: 72/255, green: 144/255, blue: 216/255, alpha: 1))

        // 테이블 헤더 구성
        setupHeaderView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView

        // 뷰 추가
        [timerLabel, resetButton, startStopButton, lapButton, tableView].forEach { addSubview($0) }

        // 레이아웃 설정
        timerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }

        resetButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        startStopButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        lapButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-60)
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(resetButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-130)
        }
    }

    /// 버튼 구성 메서드
    private func configureButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 35
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    /// 테이블 헤더 구성 메서드
    private func setupHeaderView() {
        lapLabel.text = "랩"
        lapLabel.textColor = .white
        lapLabel.font = .systemFont(ofSize: 18, weight: .medium)

        lapTimeLabel.text = "랩 타임"
        lapTimeLabel.textColor = .white
        lapTimeLabel.font = .systemFont(ofSize: 18, weight: .medium)

        totalTimeLabel.text = "전체 시간"
        totalTimeLabel.textColor = .white
        totalTimeLabel.font = .systemFont(ofSize: 18, weight: .medium)

        // 헤더 레이블 추가
        [lapLabel, lapTimeLabel, totalTimeLabel].forEach { headerView.addSubview($0) }
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)

        // 레이아웃 설정
        lapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(80)
            $0.centerY.equalToSuperview()
        }

        lapTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(lapLabel).offset(100)
            $0.centerY.equalToSuperview()
        }

        totalTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(lapTimeLabel).offset(120)
            $0.centerY.equalToSuperview()
        }
    }
}
