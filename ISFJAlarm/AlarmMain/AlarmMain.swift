//
//  ViewController.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/7/25.
//

import UIKit

import SnapKit
import Then

class ViewController: UIViewController {

    
    //MARK: UI요소
    //알람 Label
    private let alarmLabel = UILabel().then {
        $0.text = "알람"
        $0.textAlignment = .left
        $0.textColor = .label
        $0.font = UIFont.boldSystemFont(ofSize: 50)
    }
    //TableView
    private let tableView = UITableView().then {
        $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        $0.rowHeight = 90
        $0.separatorStyle = .none
        $0.backgroundColor = .systemBackground
    }
    //TableView 테스트를 위한 MockData
    private let mockData = ["A", "B", "C", "D", "E", "A", "B", "C", "D", "E", "A", "B", "C", "D", "E"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
    }
    
    //MARK: navigationBar
    private func navigationBar() {
        
        //편집버튼 설정
        let editBtn = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editBtnTapped))
        //타이틀 폰트 크기 및 색상 설정
        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20), // 폰트 크기 설정
            .foregroundColor: UIColor.systemGreen         // 텍스트 색상 설정
        ]
        editBtn.setTitleTextAttributes(leftAttributes, for: .normal)
        navigationItem.leftBarButtonItem = editBtn
        
        //+버튼 설정
        let addBtn = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addBtnTapped))
        //타이틀 폰트 크기 및 색상 설정
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30), // 폰트 크기 설정
            .foregroundColor: UIColor.systemGreen         // 텍스트 색상 설정
        ]
        addBtn.setTitleTextAttributes(rightAttributes, for: .normal)
        navigationItem.rightBarButtonItem = addBtn
        
    }
    
    //MARK: UI 정의 (네비게이션 바 포함)
    private func configureUI() {
        
        navigationBar() // 네비게이션 바
        view.backgroundColor = .systemBackground
        
        //알람 Label
        view.addSubview(alarmLabel)
        alarmLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        //TableView
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(alarmLabel.snp.bottom).offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    //MARK: Button Actions
    //알람 추가 뷰로 이동
    @objc
    private func addBtnTapped() {
        let addAlarm = AlarmEditorViewController()
        present(addAlarm, animated: true, completion: nil)
    }
    //알람 편집 부분 추가 구현 필요함.
    @objc
    private func editBtnTapped() {
        let editAlarm = AlarmEditorViewController()
        present(editAlarm, animated: true, completion: nil)
    }

}

//MARK: TableView
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: mockData[indexPath.row])
        return cell
    }
}
//MARK: Cell Click시 액션
//알람 추가 뷰로 이동
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellClicked = AlarmEditorViewController()
        present(cellClicked, animated: true, completion: nil)
    }
}

// 시스템이 들어간 색들은, 다크모드 대응해줌
