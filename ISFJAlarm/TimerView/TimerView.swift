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
    private let labelContainerView = UIView()
    private let labelTextLabel = UILabel()
    private let nameTextField = UITextField()
    private let selectedMusicLabel =  UILabel()
    private let musicContainerView = UIView()
    private let timerEndButton = UIButton()
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
        
        viewModel.$timerItems
            .receive(on: DispatchQueue.main)  // 메인 스레드에서 받기 보장
            .sink { [weak self] items in
                print("테이블뷰 리로드 시작: \(items.count)개 항목")
                self?.recentTableView.reloadData()
                print("테이블뷰 리로드 완료")
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

        // 레이블 컨테이너 설정
        labelContainerView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        labelContainerView.layer.cornerRadius = 8
        labelContainerView.clipsToBounds = true

        // 레이블 텍스트 설정
        labelTextLabel.text = "레이블"
        labelTextLabel.textColor = .white
        labelTextLabel.font = .systemFont(ofSize: 16)

        // 우측 텍스트필드 설정
        nameTextField.textColor = .white
        nameTextField.font = .systemFont(ofSize: 16)
        nameTextField.backgroundColor = .clear
        nameTextField.textAlignment = .right
        nameTextField.placeholder = "타이머" // placeholder 추가
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "타이머",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )

        // 텍스트필드 패딩 설정
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always

        // 타이머 종료 시 버튼 설정
        timerEndButton.setTitle("타이머 종료 시", for: .normal)
        timerEndButton.setTitleColor(.white, for: .normal)
        timerEndButton.titleLabel?.font = .systemFont(ofSize: 16)
        timerEndButton.contentHorizontalAlignment = .left
        timerEndButton.addTarget(self, action: #selector(timerEndButtonTapped), for: .touchUpInside)
        
        // selectedMusicLabel 설정
        selectedMusicLabel.text = "무음"
        selectedMusicLabel.textColor = .gray
        selectedMusicLabel.font = .systemFont(ofSize: 14)
        selectedMusicLabel.isUserInteractionEnabled = true  // 터치 가능하도록 설정
        
        // 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(musicLabelTapped))
        selectedMusicLabel.addGestureRecognizer(tapGesture)
        
        musicContainerView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        musicContainerView.layer.cornerRadius = 8
        musicContainerView.clipsToBounds = true
        
        // 컨트롤 버튼 설정
        setupControlButton(resetButton, systemName: "arrow.counterclockwise")
        setupControlButton(playPauseButton, systemName: "play.fill")
        playPauseButton.backgroundColor = .systemGreen
        
        // 최근 항목 레이블 설정
        recentLabel.text = "최근 항목"
        recentLabel.font = .systemFont(ofSize: 20, weight: .bold)
        recentLabel.textColor = .white
        
        // 컴포넌트 추가
        [timerLabel,hourButton, minuteButton, secondButton,hourMinusButton, minuteMinusButton, secondMinusButton,
         labelContainerView,resetButton, playPauseButton, recentLabel, recentTableView, timerEndButton, selectedMusicLabel, musicContainerView].forEach {
            view.addSubview($0)
        }
        
        labelContainerView.addSubview(labelTextLabel)
        labelContainerView.addSubview(nameTextField)
        musicContainerView.addSubview(timerEndButton)
        musicContainerView.addSubview(selectedMusicLabel)
    }
    
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
        
        labelContainerView.snp.makeConstraints { make in
            make.top.equalTo(hourMinusButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        labelTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints { make in
            make.leading.equalTo(labelTextLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(100) // 최소 너비 설정
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(musicContainerView.snp.bottom).offset(20)  // timerEndButton을 musicContainerView로 변경
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
        
        musicContainerView.snp.makeConstraints { make in
            make.top.equalTo(labelContainerView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        timerEndButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)  // labelTextLabel과 같은 위치
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        selectedMusicLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(timerEndButton.snp.trailing).offset(10)
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
        nameTextField.text = ""
    }
    
    @objc private func musicLabelTapped() {
        // 기존 timerEndButtonTapped와 동일한 동작 수행
        presentMusicSelectViewController()
    }

    // 기존 timerEndButtonTapped 메서드를 리팩토링하여 재사용 가능하게 만듦
    @objc private func timerEndButtonTapped() {
        presentMusicSelectViewController()
    }
    
    @objc private func playPauseButtonTapped() {
        if viewModel.hours == 0 && viewModel.minutes == 0 && viewModel.seconds == 0 {
            return
        }
        if !viewModel.isRunning {
            let name = nameTextField.text?.isEmpty == true ? "타이머" : nameTextField.text!
            viewModel.startTimer(withName: name)  // startAndSaveTimer 대신 startTimer 사용
        } else {
            viewModel.stopTimer()
        }
    }
    
    // 공통 기능을 별도 메서드로 분리
    private func presentMusicSelectViewController() {
        let musicVC = MusicSelectViewController()
        musicVC.delegate = self
        musicVC.modalPresentationStyle = .pageSheet
        
        if let sheet = musicVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(musicVC, animated: true)
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
        
        // 타이머 이름 설정 추가
        nameTextField.text = timer.name
        
        // 선택 효과 해제
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // 스와이프 삭제 활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 스와이프 액션 설정
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            self?.viewModel.deleteTimer(at: indexPath.row)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// TimerView에 delegate 구현 추가
extension TimerView: MusicSelectViewControllerDelegate {
    func didSelectMusic(_ music: MusicModel) {
        selectedMusicLabel.text = music.name
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
