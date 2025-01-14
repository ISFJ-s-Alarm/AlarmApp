//
//  ViewController.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/7/25.
//

import UIKit
import CoreData

import SnapKit
import Then


class ViewController: UIViewController {

    private let viewModel = AlarmMainViewModel()
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
        $0.rowHeight = 100
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
    }
    
    var alarms: [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
        
        tableView.register(MainTableViewCell.self,forCellReuseIdentifier: MainTableViewCell.identifier)
        
    }
    

    
    //MARK: navigationBar
    private func navigationBar() {
        
        //편집버튼 설정
        let editBtn = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editBtnTapped))
        //타이틀 폰트 크기 및 색상 설정
        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20), // 폰트 크기 설정
            .foregroundColor: UIColor(red: 72/255, green: 144/255, blue: 216/255, alpha: 1) // 텍스트 색상 설정
        ]
        editBtn.setTitleTextAttributes(leftAttributes, for: .normal)
        navigationItem.leftBarButtonItem = editBtn
        
        //+버튼 설정
        let addBtn = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addBtnTapped))
        //타이틀 폰트 크기 및 색상 설정
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30), // 폰트 크기 설정
            .foregroundColor: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) // 텍스트 색상 설정
        ]
        addBtn.setTitleTextAttributes(rightAttributes, for: .normal)
        navigationItem.rightBarButtonItem = addBtn
        
    }
    
    //MARK: UI 정의 (네비게이션 바 포함)
    private func configureUI() {
        
        navigationBar() // 네비게이션 바
        view.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        
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
        let vc = AlarmEditorViewController()
        vc.onSaved = { [weak self] in
            self?.alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
            DispatchQueue.main.async { //UI를 리로드할때는 항상 메인 스레드에서 실행해야함
                self?.tableView.reloadData()
            }
        }
        let addAlarm = UINavigationController(rootViewController: vc)
        present(addAlarm, animated: true, completion: nil)
    }
    //알람 편집 부분 추가 구현 필요함.
    @objc
    private func editBtnTapped() {
        let editAlarm = UINavigationController(rootViewController: AlarmEditorViewController())
        present(editAlarm, animated: true, completion: nil)
    }

}


//MARK: TableView
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone.current
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        cell.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1) // 셀 색상 설정
        let alarm = alarms[indexPath.row]
        guard let time = alarm.time else {
            return cell
        }
        let label = alarm.label ?? "No Label"
        print("time: \(dateFormatter.string(from: time)) | label: \(label)") // 확인용 print문
        cell.configureCell(with: dateFormatter.string(from: time), label: label)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            self?.viewModel.deleteAlarm(at: indexPath.row)
            completion(true)
        }
        self.viewModel.onDeleted = { [weak self] in
            self?.alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
            DispatchQueue.main.async { //UI를 리로드할때는 항상 메인 스레드에서 실행해야함
                self?.tableView.reloadData()
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

//MARK: Cell Click시 액션
//알람 추가 뷰로 이동
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellClicked = AlarmEditorViewController(alarm: alarms[indexPath.row])
        let navi = UINavigationController(rootViewController: cellClicked)
        present(navi, animated: true, completion: nil)
    }
}
    
// 시스템이 들어간 색들은, 다크모드 대응해줌

