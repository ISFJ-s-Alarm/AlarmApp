//
//  StopwatchViewCell.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/10/25.
//

import UIKit
import SnapKit

/// 스톱워치 랩 데이터를 표시하는 셀
class StopwatchLapCell: UITableViewCell {
    static let identifier = "StopwatchLapCell" // 셀 식별자

    private let lapLabel = UILabel()       // 랩 번호 레이블
    private let lapTimeLabel = UILabel()   // 랩 시간 레이블
    private let totalTimeLabel = UILabel() // 전체 시간 레이블

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UI 구성
    private func setupUI() {
        backgroundColor = .clear

        [lapLabel, lapTimeLabel, totalTimeLabel].forEach {
            $0.textColor = .white
            contentView.addSubview($0)
        }

        lapLabel.font = .systemFont(ofSize: 20, weight: .medium)
        lapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(80)
            $0.centerY.equalToSuperview()
        }

        lapTimeLabel.font = .systemFont(ofSize: 20, weight: .regular)
        lapTimeLabel.textAlignment = .center
        lapTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(lapLabel).offset(85)
            $0.centerY.equalToSuperview()
        }

        totalTimeLabel.font = .systemFont(ofSize: 20, weight: .regular)
        totalTimeLabel.textAlignment = .right
        totalTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(lapTimeLabel).offset(130)
            $0.centerY.equalToSuperview()
        }
    }

    /// 데이터 설정
    func configure(with lap: StopwatchLap) {
        lapLabel.text = "\(lap.lapNumber)"
        lapTimeLabel.text = lap.lapTime
        totalTimeLabel.text = lap.totalTime
    }
}
