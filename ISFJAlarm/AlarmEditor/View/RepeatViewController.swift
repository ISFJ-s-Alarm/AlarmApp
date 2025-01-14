//
//  RepeatViewController.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import UIKit
import SnapKit

class RepeatViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let days = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    private var selectedDays: Set<Int> = []
    
    // 돌아왔을 때 선택된 요일 받기
    init(selectedDays: [Int]) {
        super.init(nibName: nil, bundle: nil)
        self.selectedDays = Set(selectedDays)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onDaysSelected: (([Int]) -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    // MARK: - Functions
    private func setupUI() {
        view.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        
        title = "반복"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isHidden = false
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
    }
    
    private func getRepeatText() -> String {
        let selectedArray = Array(selectedDays).sorted()
        
        if selectedDays.count == 7 {
            return "매일"
        }
        
        let weekdays = Set([1, 2, 3, 4, 5])
        if selectedDays == weekdays {
            return "주중"
        }
        
        let weekend = Set([0, 6])
        if selectedDays == weekend {
            return "주말"
        }
        
        return selectedArray.map {
            String(days[$0].prefix(1))
        }.joined(separator: ",")
    }
}

// MARK: - UITableViewDataSource
extension RepeatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        
        cell.textLabel?.text = days[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        cell.accessoryType = selectedDays.contains(indexPath.row) ? .checkmark : .none
        cell.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RepeatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedDays.contains(indexPath.row) {
            selectedDays.remove(indexPath.row)
        } else {
            selectedDays.insert(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
        
        onDaysSelected?(Array(selectedDays))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
