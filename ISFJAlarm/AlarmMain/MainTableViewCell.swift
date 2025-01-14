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
        
        initCoreDataContainer()
    }

    // 초기화 실패 시 실패처리
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has no been implemented")
    }
    
    //MARK: CoreData
    // CoreData에서 값 받아오기
    var container: NSPersistentContainer!
    
    // CoreData Container 초기화
    func initCoreDataContainer() {
        container = NSPersistentContainer(name: "ISFJAlarm")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        fetchData()
    }
    
    // 데이터 로드
    func fetchData() {
        do {
            let datas = try self.container.viewContext.fetch(Alarm.fetchRequest())
            for timeNlabel in datas {
                if let time = timeNlabel.time,
                   let label = timeNlabel.label {
                }
            }
        } catch {
            print("데이터 로딩 실패")
        }
    }
    
    // CoreData에서 받은 데이터 출력
    func configureCell(with time: String, label: String) {
        timeLabel.text = time
        memoLabel.text = label
    }
    
    @objc
    private func toggleSwitch(_ sender: UISwitch) {
        print("sender.isOn", sender.isOn)
    }
}



//시스템 백그라운드 주면, 라이트/다크에 따라서 알아서 변경
