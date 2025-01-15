//
//  MainTableViewCell.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/10/25.
//

import UIKit
import CoreData

import SnapKit
import Then


class MainTableViewCell: UITableViewCell {
   static let identifier = "MainTableViewCell"
   
   //MARK: UI 요소
   // 설정된 알람 시간 label
   private let timeLabel = UILabel().then {
       $0.textColor = .white
       $0.font = .boldSystemFont(ofSize: 30)
       $0.textAlignment = .left
   }
   // 설정된 알람 메모 label
   private let memoLabel = UILabel().then {
       $0.textColor = .lightGray
       $0.font = .boldSystemFont(ofSize: 20)
       $0.textAlignment = .left
   }
   // 알람 on/off 스위치
   private let onOffSwitch = UISwitch().then {
       $0.onTintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
   }
   
   //MARK: StackView
   //StackView로 위의 3개를 하나의 cell로 표시
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
       let stackView = UIStackView(arrangedSubviews: [timeLabel, memoLabel, onOffSwitch]).then {
           $0.axis = .horizontal
           $0.spacing = 100
           $0.alignment = .center
       }
       
       contentView.addSubview(stackView)
       stackView.snp.makeConstraints {
           $0.edges.equalToSuperview().inset(10)
       }
     
       // 온오프 토글버튼 클릭 시
       onOffSwitch.addTarget(self, action: #selector(toggleSwitch), for: .touchUpInside)
   }

   // 초기화 실패 시 실패처리
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   //MARK: CoreData
   var alarm: Alarm? // 알람 객체 저장을 위한 프로퍼티
   
   func configureCell(with alarm: Alarm) {
       self.alarm = alarm
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "HH:mm"
       
       if let time = alarm.time {
           timeLabel.text = dateFormatter.string(from: time)
       }
       memoLabel.text = alarm.label ?? "알람"
       onOffSwitch.isOn = alarm.isOn
   }
   
   @objc
   private func toggleSwitch(_ sender: UISwitch) {
       guard let alarm = alarm else { return }
       AlarmCoreDataManager.shared.updateAlarm(alarm,
                                             time: nil,
                                             repeatDays: nil,
                                             label: nil,
                                             sound: nil,
                                             reminder: nil,
                                             isOn: sender.isOn)
   }
}
