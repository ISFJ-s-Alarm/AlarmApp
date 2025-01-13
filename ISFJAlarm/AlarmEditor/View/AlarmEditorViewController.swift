//
//  AlarmEditorViewController.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import UIKit
import SnapKit

class AlarmEditorViewController: UIViewController {
    private let alarmEditView = AlarmEditorView()
    private var viewModel = AlarmEditorViewModel()
    private var selectedDays: [Int] = []
    
    private var labelText: String?
    private var labelTextField: UITextField?
    
    // 기본 초기화 (새 알람 추가)
    init() {
        self.viewModel = AlarmEditorViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    // 기존 알람 편집을 위한 초기화
    init(alarm: Alarm) {
        self.viewModel = AlarmEditorViewModel(alarm: alarm)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = alarmEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButtonSetupUI()
        setupBindings()
        setupActions()
        setupInitialState()
        
        alarmEditView.tableView.dataSource = self
        alarmEditView.tableView.delegate = self
    }
    
    private func backButtonSetupUI() {
        let backBarButton = UIBarButtonItem(title: "뒤로", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        navigationController?.navigationBar.tintColor = .orange
    }
    
    private func setupBindings() {
        viewModel.updateUI = { [weak self] in
            self?.alarmEditView.tableView.reloadData()
        }
    }
    
    private func setupActions() {
        alarmEditView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        alarmEditView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        alarmEditView.timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
    }
    
    private func setupInitialState() {
        // TimePicker 초기값 설정
        alarmEditView.timePicker.date = viewModel.getTime()
        alarmEditView.timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        
        // 기존 데이터가 있다면 selectedDays 설정
        selectedDays = viewModel.getSelectedDays()
        
        // 레이블 초기값 설정
        labelText = viewModel.getLabel()
        
        alarmEditView.configure(with: viewModel.existingAlarm)
    }
    
    private func updateSelectedDays(_ days: [Int]) {
        selectedDays = days
        viewModel.setSelectedDays(days)
        alarmEditView.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        viewModel.setTime(alarmEditView.timePicker.date)
        
        let saveResult = viewModel.saveAlarm()
        print("알람 \(viewModel.isEditing ? "수정" : "저장") 결과: \(saveResult)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone.current
        
        let allAlarms = AlarmCoreDataManager.shared.fetchAllAlarms()
        print("현재 저장된 모든 알람:")
        allAlarms.forEach { alarm in
            if let time = alarm.time {
                print("시간: \(dateFormatter.string(from: time))")
            }
            print("레이블: \(alarm.label ?? "")")
            print("반복: \(AlarmCoreDataManager.shared.decodeRepeatDays(from: alarm.repeatDays))")
            print("사운드: \(alarm.sound ?? "")")
            print("다시 알림: \(alarm.reminder)")
            print("------------------------")
        }
        
        dismiss(animated: true)
    }
    
    @objc private func timePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.setTime(sender.date)
    }

    @objc private func timeChanged(_ sender: UIDatePicker) {
        viewModel.setTime(sender.date)
    }
    
    @objc private func reminderSwitchChanged(_ sender: UISwitch) {
        viewModel.toggleReminder()
    }
}

// MARK: - extension
extension AlarmEditorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .darkGray
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        let backgrounView = UIView()
        backgrounView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        cell.selectedBackgroundView = backgrounView
        
        cell.textLabel?.textColor = .white
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "반복"
            
            if !selectedDays.isEmpty {
                let repeatText = getRepeatText(selectedDays)
                let label = UILabel()
                label.text = repeatText
                label.textColor = .lightGray
                
                cell.contentView.addSubview(label)
                label.snp.makeConstraints {
                    $0.trailing.equalToSuperview().offset(-20)
                    $0.centerY.equalToSuperview()
                }
            } else {
                let label = UILabel()
                label.text = "안함"
                label.textColor = .lightGray
                
                cell.contentView.addSubview(label)
                label.snp.makeConstraints {
                    $0.trailing.equalToSuperview().offset(-20)
                    $0.centerY.equalToSuperview()
                }
            }
        
        case 1:
            cell.textLabel?.text = "레이블"
            let textField = UITextField()
            labelTextField = textField
            
            let placeholderText = "알람"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
            textField.text = labelText
            textField.textColor = .lightGray
            textField.delegate = self
            textField.tag = 1
            textField.clearButtonMode = .whileEditing
            textField.textAlignment = .right
            textField.returnKeyType = .done
            
            cell.contentView.addSubview(textField)
            textField.snp.makeConstraints {
                $0.trailing.equalTo(cell.contentView).offset(-20)
                $0.centerY.equalTo(cell.contentView)
                $0.leading.greaterThanOrEqualTo(cell.contentView).offset(10)
            }
        case 2:
            cell.textLabel?.text = "사운드"
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.textLabel?.text = "다시 알림"
            let switchControl = UISwitch()
            switchControl.isOn = viewModel.getReminderStatus()
            switchControl.addTarget(self, action: #selector(reminderSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        default:
            break
        }
        return cell
    }
    
    private func getRepeatText(_ days: [Int]) -> String {
            let sortedDays = days.sorted()
            let weekdays = Set([1, 2, 3, 4, 5])
            let weekend = Set([0, 6])
            let allDays = Set(0...6)
            
            if Set(days) == allDays {
                return "매일"
            } else if Set(days) == weekdays {
                return "주중"
            } else if Set(days) == weekend {
                return "주말"
            } else {
                let daySymbols = ["일", "월", "화", "수", "목", "금", "토"]
                return sortedDays.map { daySymbols[$0] }.joined(separator: ",")
            }
        }
}
    
extension AlarmEditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let repeatVC = RepeatViewController(selectedDays: selectedDays)
            repeatVC.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                self?.viewModel.setSelectedDays(days)
                self?.alarmEditView.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            navigationController?.pushViewController(repeatVC, animated: true)
        case 1:
            labelTextField?.becomeFirstResponder()
        case 2:
            let soundVC = SoundViewController()
            self.navigationController?.pushViewController(soundVC, animated: true)
        case 3:
            if let cell = tableView.cellForRow(at: indexPath), let switchControl = cell.accessoryView as? UISwitch {
                // Todo: switchControl.isOn 상태 처리 로직
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension AlarmEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        alarmEditView.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .middle, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            labelText = textField.text
            viewModel.setLabel(textField.text ?? "")
            alarmEditView.tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
