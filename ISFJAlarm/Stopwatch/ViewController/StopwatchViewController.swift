//
//  StopwatchViewController.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/10/25.
//

import UIKit
import Combine

/// 스톱워치 화면을 관리하는 뷰 컨트롤러
class StopwatchViewController: UIViewController {
    private let stopwatchView = StopwatchView() // 커스텀 뷰
    private let viewModel = StopwatchViewModel() // 스톱워치 뷰모델
    private var cancellables = Set<AnyCancellable>() // Combine을 위한 구독 저장소

    /// 뷰를 설정
    override func loadView() {
        view = stopwatchView
    }

    /// 초기 설정
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupActions()
        setupTableView()
    }

    /// 뷰모델과 바인딩 설정
    private func setupBindings() {
        // 타이머 텍스트 업데이트
        viewModel.$timerText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.stopwatchView.timerLabel.text = text
            }
            .store(in: &cancellables)

        // 랩 데이터 업데이트
        viewModel.$laps
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.stopwatchView.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    /// 버튼 액션 설정
    private func setupActions() {
        stopwatchView.startStopButton.addTarget(self, action: #selector(startStopTapped), for: .touchUpInside)
        stopwatchView.resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        stopwatchView.lapButton.addTarget(self, action: #selector(lapTapped), for: .touchUpInside)
    }

    /// 테이블 뷰 초기화
    private func setupTableView() {
        stopwatchView.tableView.delegate = self
        stopwatchView.tableView.dataSource = self
        stopwatchView.tableView.register(StopwatchLapCell.self, forCellReuseIdentifier: StopwatchLapCell.identifier)
    }

    /// 시작/정지 버튼 클릭 처리
    @objc private func startStopTapped() {
        viewModel.startStopTimer()
    }

    /// 리셋 버튼 클릭 처리
    @objc private func resetTapped() {
        viewModel.resetTimer()
    }

    /// 랩 버튼 클릭 처리
    @objc private func lapTapped() {
        viewModel.recordLap()
    }
}

extension StopwatchViewController: UITableViewDataSource, UITableViewDelegate {
    /// 섹션의 행 수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.laps.count
    }
    
    /// 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StopwatchLapCell.identifier, for: indexPath) as? StopwatchLapCell else {
            return UITableViewCell()
        }
        let lap = viewModel.laps[indexPath.row]
        cell.configure(with: lap)
        return cell
    }
    
    /// 행 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    /// 섹션 헤더 뷰 반환
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return stopwatchView.headerView
    }

    /// 섹션 헤더 높이 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}
