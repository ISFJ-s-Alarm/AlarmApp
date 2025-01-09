//
//  TimerView.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/7/25.
//

import UIKit
import SnapKit
import Combine
import CoreData

class TimerView: UIViewController {
    // MARK: - Properties
    private let viewModel = TimerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let timerLabel = UILabel()
    private let hourButton = UIButton()
    private let minuteButton = UIButton()
    private let secondButton = UIButton()
    private let resetButton = UIButton()
    private let playPauseButton = UIButton()
    private let labelTextField = UITextField()
    private let recentLabel = UILabel()
    private let recentTableView = UITableView()
    private let hourMinusButton = UIButton()
    private let minuteMinusButton = UIButton()
    private let secondMinusButton = UIButton()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        viewModel.loadTimers()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$isRunning
            .sink { [weak self] isRunning in
                let imageName = isRunning ? "pause.fill" : "play.fill"
                self?.playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.$timerItems
            .sink { [weak self] _ in
                self?.recentTableView.reloadData()
            }
            .store(in: &cancellables)
            
        viewModel.$hours
            .combineLatest(viewModel.$minutes, viewModel.$seconds)
            .sink { [weak self] hours, minutes, seconds in
                self?.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setupBasic()
        setupComponents()
        setupConstraints()
        setupTableView()
    }
    
    private func setupBasic() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupComponents() {
        
        // 타이머 레이블 설정
        timerLabel.text = "00:00:00"
        timerLabel.font = .systemFont(ofSize: 80, weight: .regular)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        
        // 시간 증가 버튼 설정
        setupTimeButton(hourButton, title: "시 +")
        setupTimeButton(minuteButton, title: "분 +")
        setupTimeButton(secondButton, title: "초 +")
        
        // 시간 감소 버튼 설정
        setupTimeButton(hourMinusButton, title: "시 -")
        setupTimeButton(minuteMinusButton, title: "분 -")
        setupTimeButton(secondMinusButton, title: "초 -")
        
        // 레이블 입력 텍스트필드 설정
        labelTextField.placeholder = "타이머명"
        labelTextField.attributedPlaceholder = NSAttributedString(
            string: "타이머명",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        labelTextField.textColor = .white
        labelTextField.textAlignment = .center
        labelTextField.font = .systemFont(ofSize: 16)
        labelTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        labelTextField.layer.cornerRadius = 8
        labelTextField.clipsToBounds = true
        
        // 텍스트필드 패딩 설정
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: labelTextField.frame.height))
        labelTextField.leftView = paddingView
        labelTextField.leftViewMode = .always
        labelTextField.rightView = paddingView
        labelTextField.rightViewMode = .always
        
        // 컨트롤 버튼 설정
        setupControlButton(resetButton, systemName: "arrow.counterclockwise")
        setupControlButton(playPauseButton, systemName: "play.fill")
        playPauseButton.backgroundColor = .systemGreen
        
        // 최근 항목 레이블 설정
        recentLabel.text = "최근 항목"
        recentLabel.font = .systemFont(ofSize: 20, weight: .bold)
        recentLabel.textColor = .white
        
        // 뷰에 컴포넌트 추가
        [timerLabel,
         hourButton, minuteButton, secondButton,
         hourMinusButton, minuteMinusButton, secondMinusButton,
         labelTextField, resetButton, playPauseButton, recentLabel, recentTableView].forEach {
            view.addSubview($0)
        }
    }
    
    // 버튼 기능 설정
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
        case "시 -": button.addTarget(self, action: #selector(hourMinusButtonTapped), for: .touchUpInside)
        case "분 -": button.addTarget(self, action: #selector(minuteMinusButtonTapped), for: .touchUpInside)
        case "초 -": button.addTarget(self, action: #selector(secondMinusButtonTapped), for: .touchUpInside)
        default: break
        }
    }
    
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
    
    private func setupTableView() {
        recentTableView.backgroundColor = .clear
        recentTableView.register(TimerTableViewCell.self, forCellReuseIdentifier: TimerTableViewCell.identifier)
        recentTableView.delegate = self
        recentTableView.dataSource = self
    }
    
    // MARK: - Auto Layout
    private func setupConstraints() {
        
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
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
        
        hourMinusButton.snp.makeConstraints { make in
            make.top.equalTo(hourButton.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 60) / 3)
            make.height.equalTo(40)
        }

        minuteMinusButton.snp.makeConstraints { make in
            make.top.equalTo(hourMinusButton)
            make.leading.equalTo(hourMinusButton.snp.trailing).offset(10)
            make.width.height.equalTo(hourMinusButton)
        }

        secondMinusButton.snp.makeConstraints { make in
            make.top.equalTo(hourMinusButton)
            make.leading.equalTo(minuteMinusButton.snp.trailing).offset(10)
            make.width.height.equalTo(hourMinusButton)
        }
        
        labelTextField.snp.makeConstraints { make in
            make.top.equalTo(hourMinusButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(labelTextField.snp.bottom).offset(20)
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
    
    // MARK: - Button Actions
    @objc private func hourButtonTapped() {
        viewModel.incrementHours()
    }
    
    @objc private func minuteButtonTapped() {
        viewModel.incrementMinutes()
    }
    
    @objc private func secondButtonTapped() {
        viewModel.incrementSeconds()
    }
    
    @objc private func hourMinusButtonTapped() {
        viewModel.decrementHours()
    }

    @objc private func minuteMinusButtonTapped() {
        viewModel.decrementMinutes()
    }

    @objc private func secondMinusButtonTapped() {
        viewModel.decrementSeconds()
    }
    
    @objc private func resetButtonTapped() {
        viewModel.resetTimer()
        labelTextField.text = ""
    }
    
    @objc private func playPauseButtonTapped() {
        if viewModel.isRunning {
            viewModel.stopTimer()
        } else {
            if let name = labelTextField.text, !name.isEmpty {
                viewModel.saveTimer(name: name)
            }
            viewModel.startTimer()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TimerView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.timerItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimerTableViewCell.identifier, for: indexPath) as? TimerTableViewCell else {
            return UITableViewCell()
        }
        
        let timer = viewModel.timerItems[indexPath.row]
        cell.configure(with: timer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // 셀 선택 시 동작
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timer = viewModel.timerItems[indexPath.row]
        
        // 타이머 값 설정
        viewModel.setTimer(hours: timer.hours,
                          minutes: timer.minutes,
                          seconds: timer.seconds)
        
        // 타이머 이름 설정
        labelTextField.text = timer.name
        
        // 선택 효과 해제
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SwiftUI Preview
@available(iOS 17.0, *)
#Preview {
    let viewController = TimerView()
    let navigationController = UINavigationController(rootViewController: viewController)
    
    // Preview용 CoreData 설정
    let momName = "Timer"
    let model = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
    let container = NSPersistentContainer(name: momName, managedObjectModel: model)
    
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { _, error in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    TimerCoreDataManager.shared.persistentContainer = container
    
    return navigationController
}