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
    
    // 설정된 알람 시간 label
    private let timeLabel = UILabel().then {
        $0.textColor = .label //라이트/다크모드에 따라서 알아서 색변경
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .left
    }
    // 설정된 알람 메모 label
    private let memoLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .left
    }
    // 알람 on/off 스위치. 추가 구현 필요함
    private let onOffSwitch = UISwitch()
    
    
    
    //UIViewController에 / viewDidLoad에서 / foo 호출함
    //UITableViewCell에 /   초기화할때      / foo 대신 addTarget 호출함
    //
    //class는 init을 통해서 생성
    
    //StackView로 위의 3개를 하나의 cell로 표시
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        // StackView
        let stackView = UIStackView(arrangedSubviews: [timeLabel, memoLabel, onOffSwitch])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 150
        stackView.alignment = .center
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
    
//    // CoreData에서 받은 데이터 출력
//    func configureCell(with text: String) {
//        timeLabel.text = text
//        memoLabel.text = text
//    }
    
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
                    print("name: \(time), label: \(label)")
                }
            }
        } catch {
            print("데이터 로딩 실패")
        }
    }
    
    // CoreData에서 받은 데이터 출력
    func configureCell(with text: String) {
        timeLabel.text = text
        memoLabel.text = text
    }
    
    @objc
    private func toggleSwitch(_ sender: UISwitch) {
        print("sender.isOn", sender.isOn)
    }
}



//시스템 백그라운드 주면, 라이트/다크에 따라서 알아서 변경
