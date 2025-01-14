//
//  StopwatchView.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/10/25.
//
import UIKit
import SnapKit

/// 스톱워치 화면 뷰
class StopwatchView: UIView, UITableViewDelegate, UITableViewDataSource {
    let timerLabel = UILabel()       // 타이머 표시 레이블
    let lapButton = UIButton()       // 랩 버튼
    let resetButton = UIButton()     // 리셋 버튼
    let startStopButton = UIButton() // 시작/정지 버튼
    let tableView = UITableView()    // 랩 기록 표시 테이블
    let headerView = UIView()        // 테이블 헤더
    let lapLabel = UILabel()         // 헤더의 랩 레이블
    let lapTimeLabel = UILabel()     // 헤더의 랩 타임 레이블
    let totalTimeLabel = UILabel()   // 헤더의 전체 시간 레이블

    var lapTimes: [(lap: Int, lapTime: String, totalTime: String)] = [] // 랩 타임 데이터 배열

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UI 구성 메서드
    private func setupUI() {
        backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)

        // 타이머 레이블 설정
        timerLabel.text = "00:00.00"
        timerLabel.font = .systemFont(ofSize: 80, weight: .regular)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center

        // 버튼 구성
        configureButton(resetButton, systemName: "arrow.counterclockwise", color: UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1))
        configureButton(startStopButton, systemName: "play.fill", color: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1))
        configureButton(lapButton, systemName: "flag.fill", color: UIColor(red: 72/255, green: 144/255, blue: 216/255, alpha: 1))

        // 테이블 헤더 구성
        setupHeaderView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView

        // 뷰 계층 추가
        [timerLabel, resetButton, startStopButton, lapButton, tableView].forEach { addSubview($0) }

        // 레이아웃 설정
        timerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }

        resetButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        startStopButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        lapButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-60)
            $0.top.equalTo(timerLabel.snp.bottom).offset(40)
            $0.width.height.equalTo(70)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(startStopButton.snp.bottom).offset(40)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-130)
        }
    }

    /// 버튼 구성 메서드
    private func configureButton(_ button: UIButton, systemName: String, color: UIColor) {
        let icon = UIImage(systemName: systemName)
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = color
        button.layer.cornerRadius = 35
        button.imageView?.contentMode = .scaleAspectFit
    }

    /// 테이블 헤더 구성 메서드
    private func setupHeaderView() {
        // 레이블 속성 설정
        lapLabel.text = "랩"
        lapLabel.textColor = .white
        lapLabel.font = .systemFont(ofSize: 20, weight: .medium)

        lapTimeLabel.text = "랩 타임"
        lapTimeLabel.textColor = .white
        lapTimeLabel.font = .systemFont(ofSize: 18, weight: .medium)

        totalTimeLabel.text = "전체 시간"
        totalTimeLabel.textColor = .white
        totalTimeLabel.font = .systemFont(ofSize: 18, weight: .medium)

        // 헤더에 레이블 추가
        [lapLabel, lapTimeLabel, totalTimeLabel].forEach { headerView.addSubview($0) }

        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)

        lapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(70)
            $0.centerY.equalToSuperview()
        }

        lapTimeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        totalTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-60)
            $0.centerY.equalToSuperview()
        }
    }

    /// 테이블 뷰 설정
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LapCell")
    }

    // MARK: - TableView Delegate & DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LapCell", for: indexPath)
        let lapData = lapTimes[indexPath.row]
        cell.textLabel?.text = "랩 \(lapData.lap)    \(lapData.lapTime)    \(lapData.totalTime)"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        return cell
    }

    func addLap(lap: Int, lapTime: String, totalTime: String) {
        lapTimes.insert((lap, lapTime, totalTime), at: 0)
        tableView.reloadData()
    }
}
