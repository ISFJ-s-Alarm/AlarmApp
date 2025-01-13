//
//  MainTableViewCell.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/10/25.
//

import UIKit

import SnapKit
import Then

class MainTableViewCell: UITableViewCell {
    static let identifier = "MainTableViewCell"
    
    //설정된 알람 시간 label
    private let timeLabel = UILabel().then {
        $0.textColor = .label //라이트/다크모드에 따라서 알아서 색변경
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .left
    }
    //설정된 알람 메모 label
    private let memoLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .left
    }
    //알람 on/off 스위치. 추가 구현 필요함
    private let onOffSwitch = UISwitch()
    
    //StackView로 위의 3개를 하나의 cell로 표시
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, memoLabel, onOffSwitch])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 150
        stackView.alignment = .center
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has no been implemented")
    }
    
    func configureCell(with text: String) {
        timeLabel.text = text
        memoLabel.text = text
    }
}


//시스템 백그라운드 주면, 라이트/다크에 따라서 알아서 변경
