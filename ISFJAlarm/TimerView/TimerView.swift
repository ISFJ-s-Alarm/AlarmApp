//
//  TimerView.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/7/25.
//

import UIKit
import SnapKit

// MARK: - TimerView
/// 타이머 화면을 구성하고 시간 설정 및 카운트다운을 처리하는 뷰 컨트롤러
class TimerView: UIViewController {
    
    // MARK: - Properties
    /// 타이머 제목 레이블
    private let titleLabel = UILabel()
    
    /// 타이머 시간 표시 레이블
    private let timerLabel = UILabel()
    
    /// 시간 증가 버튼
    private let hourButton = UIButton()
    
    /// 분 증가 버튼
    private let minuteButton = UIButton()
    
    /// 초 증가 버튼
    private let secondButton = UIButton()
    
    /// 리셋 버튼
    private let resetButton = UIButton()
    
    /// 시작/일시정지 버튼
    private let playPauseButton = UIButton()
    
    /// 최근 항목 레이블
    private let recentLabel = UILabel()
    
    /// 최근 타이머 목록을 표시할 테이블뷰
    private let recentTableView = UITableView()
    
    /// 타이머 시간 값
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    
    /// 타이머
    private var timer: Timer?
    private var isRunning = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Configuration
    /// UI 요소 설정 및 레이아웃 구성
    private func configureUI() {
        setupBasic()
        setupComponents()
        setupConstraints()
        setupTableView()
    }
    
    /// 기본 설정
    private func setupBasic() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    /// UI 컴포넌트 설정
    private func setupComponents() {
        // 타이틀 레이블 설정
        titleLabel.text = "타이머"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        
        // 타이머 레이블 설정
        timerLabel.text = "00:00:00"
        timerLabel.font = .systemFont(ofSize: 80, weight: .regular)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        
        // 시간 버튼 설정
        setupTimeButton(hourButton, title: "시 +")
        setupTimeButton(minuteButton, title: "분 +")
        setupTimeButton(secondButton, title: "초 +")
        
        // 컨트롤 버튼 설정
        setupControlButton(resetButton, systemName: "arrow.counterclockwise")
        setupControlButton(playPauseButton, systemName: "play.fill")
        playPauseButton.backgroundColor = .systemGreen
        
        // 최근 항목 레이블 설정
        recentLabel.text = "최근 항목"
        recentLabel.font = .systemFont(ofSize: 20, weight: .bold)
        recentLabel.textColor = .white
        
        // 뷰에 컴포넌트 추가
        [titleLabel, timerLabel, hourButton, minuteButton, secondButton,
         resetButton, playPauseButton, recentLabel, recentTableView].forEach {
            view.addSubview($0)
        }
    }
    
    /// 시간 설정 버튼 공통 설정
    private func setupTimeButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        switch title {
        case "시 +": button.addTarget(self, action: #selector(hourButtonTapped), for: .touchUpInside)
        case "분 +": button.addTarget(self, action: #selector(minuteButtonTapped), for: .touchUpInside)
        case "초 +": button.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        default: break
        }
    }
    
    /// 컨트롤 버튼 공통 설정
    private func setupControlButton(_ button: UIButton, systemName: String) {
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 35
        
        if button == resetButton {
            button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        }
    }
    
    /// 테이블뷰 설정
    private func setupTableView() {
        recentTableView.backgroundColor = .clear
        recentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TimerCell")
        recentTableView.delegate = self
        recentTableView.dataSource = self
    }
    
    // MARK: - Auto Layout
    /// SnapKit을 활용한 제약조건 설정
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        hourButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 60) / 3)
            make.height.equalTo(40)
        }
        
        minuteButton.snp.makeConstraints { make in
            make.top.equalTo(hourButton)
            make.leading.equalTo(hourButton.snp.trailing).offset(10)
            make.width.height.equalTo(hourButton)
        }
        
        secondButton.snp.makeConstraints { make in
            make.top.equalTo(hourButton)
            make.leading.equalTo(minuteButton.snp.trailing).offset(10)
            make.width.height.equalTo(hourButton)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(hourButton.snp.bottom).offset(40)
            make.trailing.equalTo(view.snp.centerX).offset(-20)
            make.width.height.equalTo(70)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(resetButton)
            make.leading.equalTo(view.snp.centerX).offset(20)
            make.width.height.equalTo(resetButton)
        }
        
        recentLabel.snp.makeConstraints { make in
            make.top.equalTo(resetButton.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        recentTableView.snp.makeConstraints { make in
            make.top.equalTo(recentLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Actions
    @objc private func hourButtonTapped() {
        hours = (hours + 1) % 24
        updateTimerLabel()
    }
    
    @objc private func minuteButtonTapped() {
        minutes = (minutes + 1) % 60
        updateTimerLabel()
    }
    
    @objc private func secondButtonTapped() {
        seconds = (seconds + 1) % 60
        updateTimerLabel()
    }
    
    @objc private func resetButtonTapped() {
        stopTimer()
        hours = 0
        minutes = 0
        seconds = 0
        updateTimerLabel()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    @objc private func playPauseButtonTapped() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        guard timer == nil else { return }
        if hours == 0 && minutes == 0 && seconds == 0 { return }
        
        isRunning = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private func updateTimer() {
        if seconds > 0 {
            seconds -= 1
        } else if minutes > 0 {
            minutes -= 1
            seconds = 59
        } else if hours > 0 {
            hours -= 1
            minutes = 59
            seconds = 59
        } else {
            stopTimer()
            // TODO: 타이머 종료 알림 추가
        }
        
        updateTimerLabel()
    }
    
    private func updateTimerLabel() {
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TimerView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // 최근 타이머 항목 개수
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        
        // 샘플 데이터
        let times = ["라면", "명상", "운동", "스터디"]
        let durations = ["00:03:00", "00:10:00", "00:30:00", "01:00:00"]
        
        cell.textLabel?.text = "\(times[indexPath.row])     \(durations[indexPath.row])"
        
        return cell
    }
}

// MARK: - SwiftUI Preview
@available(iOS 17.0, *)
#Preview {
    TimerView()
}
