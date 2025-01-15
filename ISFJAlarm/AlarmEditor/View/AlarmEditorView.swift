//
//  AlarmEditorView.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import UIKit
import SnapKit

class AlarmEditorView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "알람 추가"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
        return button
    }()
    
    let timePicker: UIDatePicker = {
        let
        picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        return tableView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        
        [titleLabel, cancelButton, saveButton, timePicker, tableView]
            .forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(titleLabel)
        }
        
        saveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(titleLabel)
        }
        
        timePicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(timePicker.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        
    }
}

// MARK: - Extension
extension AlarmEditorView {
    func updateTitle(isEditing: Bool) {
        titleLabel.text = isEditing ? "알람 편집" : "알람 추가"
    }
    
    func configure(with alarm: Alarm?) {
        if let alarm = alarm {
            timePicker.date = alarm.time ?? Date()
        }
    }
}
