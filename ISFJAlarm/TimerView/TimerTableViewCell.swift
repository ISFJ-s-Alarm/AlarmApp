//
//  TimerTableViewCell.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/9/25.
//

import UIKit
import SnapKit

class TimerTableViewCell: UITableViewCell {
    static let identifier = "TimerTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-20)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(100) // 시간 레이블의 고정 너비
        }
    }
    
    func configure(with timer: TimerModel) {
        nameLabel.text = timer.name
        timeLabel.text = timer.formattedTime
    }
}
