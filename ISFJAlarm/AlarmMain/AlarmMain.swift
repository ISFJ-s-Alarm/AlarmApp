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

    private static var lastMinute = -1
    
    private let viewModel = AlarmMainViewModel()
    private var timer: Timer?  // timer 프로퍼티 추가
    
    //MARK: UI요소
    //알람 Label
    private let alarmLabel = UILabel().then {
        $0.text = "알람"
        $0.textAlignment = .left
        $0.textColor = .white
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
        print("📱 ViewController가 로드됨")
        configureUI()
        alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
        print("⏰ 총 알람 개수: \(alarms.count)")
        
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        startAlarmTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 화면이 나타날 때마다 타이머 재시작
        startAlarmTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil  // 타이머 완전 해제
    }

    
    //MARK: navigationBar
    private func navigationBar() {
        
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
    
    private func startAlarmTimer() {
        print("⏰ 알람 타이머 시작")
        // RunLoop.main에 타이머 추가하여 백그라운드에서도 동작하도록 설정
        timer = Timer(timeInterval: 1, target: self, selector: #selector(checkAlarms), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        print("⏰ 타이머 설정 완료")
    }
    
    //MARK: UI 정의 (네비게이션 바 포함)
    private func configureUI() {
        
        navigationBar() // 네비게이션 바
        view.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        
        //알람 Label
        view.addSubview(alarmLabel)
        alarmLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
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
    
    @objc private func checkAlarms() {
        let now = Date()
        let calendar = Calendar.current
        
        let nowHour = calendar.component(.hour, from: now)
        let nowMinute = calendar.component(.minute, from: now)
        let nowSecond = calendar.component(.second, from: now)
        
        // 매번 알람 목록 새로 로드
        alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
        
        // 로그는 1분에 한 번만
        if nowSecond == 0 {
            print("\n🕒 현재 시각: \(String(format: "%02d:%02d:%02d", nowHour, nowMinute, nowSecond))")
            print("\n📱 활성화된 알람 목록:")
            for alarm in alarms where alarm.isOn {
                guard let alarmTime = alarm.time else { continue }
                let alarmHour = calendar.component(.hour, from: alarmTime)
                let alarmMinute = calendar.component(.minute, from: alarmTime)
                print("- \(String(format: "%02d:%02d", alarmHour, alarmMinute)) (\(alarm.sound ?? "무음"))")
            }
        }
        
        // 모든 알람 체크
        for alarm in alarms {
            guard let alarmTime = alarm.time,
                  alarm.isOn else { continue }
            
            let alarmHour = calendar.component(.hour, from: alarmTime)
            let alarmMinute = calendar.component(.minute, from: alarmTime)
            
            // 정각에 한 번만 알람이 울리도록
            if nowHour == alarmHour &&
               nowMinute == alarmMinute &&
               nowSecond == 0 {
                
                print("\n🔔 알람 발생!")
                print("시간: \(String(format: "%02d:%02d", alarmHour, alarmMinute))")
                print("소리: \(alarm.sound ?? "무음")")
                
                DispatchQueue.main.async { [weak self] in
                    if self?.presentedViewController == nil {
                        self?.showAlertView(for: alarm)
                    }
                }
            }
        }
    }
    
    private func showAlertView(for alarm: Alarm) {
        print("\n💡 알람 화면 표시 시작")
        print("- 소리: \(alarm.sound ?? "없음")")
        print("- 다시 알림: \(alarm.reminder)")
        
        let alertVC = AlertViewController()
        alertVC.reminderEnabled = alarm.reminder
        alertVC.selectedSound = alarm.sound
        alertVC.modalPresentationStyle = .fullScreen
        
        // 알람이 여러 번 표시되는 것을 방지
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.presentedViewController == nil {
                self.present(alertVC, animated: true)
            }
        }
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

}


//MARK: TableView
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        cell.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        let alarm = alarms[indexPath.row]
        cell.configureCell(with: alarm)
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
        // 수정 완료 후 콜백 추가
        cellClicked.onSaved = { [weak self] in
            self?.alarms = AlarmCoreDataManager.shared.fetchAllAlarms()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        let navi = UINavigationController(rootViewController: cellClicked)
        present(navi, animated: true, completion: nil)
    }
}
