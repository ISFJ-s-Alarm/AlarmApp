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
    
    var onSaved: (() -> Void) = { }
    
    // 기본 초기화 (새 알람 추가)
    init() {
        self.viewModel = AlarmEditorViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    // 기존 알람 편집을 위한 초기화
    init(alarm: Alarm) {
        self.viewModel = AlarmEditorViewModel(alarm: alarm) // 기존 알람 전달
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
        
        // 화면 어디든 터치하면 키보드가 내려감
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Functions
    private func backButtonSetupUI() {
        let backBarButton = UIBarButtonItem(title: "뒤로", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        navigationController?.navigationBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
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
        
        if viewModel.isEditing {
            alarmEditView.updateTitle(isEditing: true) // "알람 편집"으로 변경
        } else {
            alarmEditView.updateTitle(isEditing: false) // "알람 추가"로 설정
        }
        
        // TimePicker 초기값 설정
        alarmEditView.timePicker.date = viewModel.getTime()
        
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
        
        if saveResult {
            // 저장 성공 시 AlertViewController로 데이터 전달
            let alertVC = AlertViewController()
            alertVC.reminderEnabled = viewModel.reminder // "다시 알림" 상태 전달
        } else {
            print("알람 저장 실패")
        }
        
        // Debugging: 저장된 알람 출력
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
        
        onSaved()
        dismiss(animated: true)
    }
    
    @objc private func timePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.setTime(sender.date)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func reminderSwitchChanged(_ sender: UISwitch) {
        viewModel.toggleReminder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            textField.text = ""
            viewModel.setLabel("")
        }
    }
}

// MARK: - UITableViewDataSource
extension AlarmEditorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .clear
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
            
            // clearButton 이미지 색상 변경
            if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
                clearButton.setImage(clearButton.image(for: .normal)?.withTintColor(.lightGray, renderingMode: .alwaysOriginal), for: .normal)
            }
            
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            cell.contentView.addSubview(textField)
            textField.snp.makeConstraints {
                $0.trailing.equalTo(cell.contentView).offset(-20)
                $0.centerY.equalTo(cell.contentView)
                $0.leading.greaterThanOrEqualTo(cell.contentView).offset(10)
            }
        case 2:
            cell.textLabel?.text = "사운드"
            let soundLabel = UILabel()
            soundLabel.text = viewModel.getSound()
            soundLabel.textColor = .lightGray
            
            cell.contentView.addSubview(soundLabel)
            soundLabel.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-20)
                $0.centerY.equalToSuperview()
            }
        case 3:
            cell.textLabel?.text = "다시 알림"
            let switchControl = UISwitch()
            switchControl.isOn = viewModel.getReminderStatus()
            switchControl.onTintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
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

// MARK: - UITableViewDelegate
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
            let soundVC = SoundViewController(selectedSound: viewModel.getSound())
            soundVC.delegate = self
            navigationController?.pushViewController(soundVC, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITextFieldDelegate
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

// MARK: - SoundViewControllerDelegate
extension AlarmEditorViewController: SoundViewControllerDelegate {
    func didSelectSound(_ sound: String) {
        viewModel.setSound(sound)
        alarmEditView.tableView.reloadData()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AlarmEditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // clearButton을 터치했을 때는 제스처 인식기 동작 무시
        if let clearButton = labelTextField?.value(forKey: "_clearButton") as? UIButton,
           touch.view == clearButton {
            return false
        }
        
        // 테이블뷰 터치 시 제스처 인식기 동작 무시
        if touch.view?.isDescendant(of: alarmEditView.tableView) == true {
            return false
        }
        return true
    }
}
