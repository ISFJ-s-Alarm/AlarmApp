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
    private var hourArray: [Int] = Array(0...23)
    private var minuteArray: [Int] = Array(0...59)
    private var secondArray: [Int] = Array(0...59)

    // MARK: - UI Components
    private let timerLabel = UILabel()
    private let resetButton = UIButton()
    private let playPauseButton = UIButton()
    private let labelContainerView = UIView()
    private let labelTextLabel = UILabel()
    private let nameTextField = UITextField()
    private let selectedMusicLabel = UILabel()
    private let musicContainerView = UIView()
    private let timerEndButton = UIButton()
    private let recentLabel = UILabel()
    private let recentTableView = UITableView()
    private let timePickerView = UIPickerView()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupPickerView()
        setupBindings()
        // viewModel.loadTimers()
        viewModel.delegate = self  // 델리게이트 설정
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
            .receive(on: DispatchQueue.main)
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
        
        // PickerView 바인딩
        viewModel.$hours
            .combineLatest(viewModel.$minutes, viewModel.$seconds)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hours, minutes, seconds in
                guard let self = self else { return }
                // 범위 체크 추가
                if hours < self.hourArray.count {
                    self.timePickerView.selectRow(hours, inComponent: 0, animated: false)
                }
                if minutes < self.minuteArray.count {
                    self.timePickerView.selectRow(minutes, inComponent: 1, animated: false)
                }
                if seconds < self.secondArray.count {
                    self.timePickerView.selectRow(seconds, inComponent: 2, animated: false)
                }
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
        view.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        navigationController?.navigationBar.isHidden = true
    }

    private func setupComponents() {
        // 타이머 피커뷰 설정
        timePickerView.backgroundColor = .clear
        
        // 타이머 레이블 설정
        timerLabel.text = "00:00:00"
        timerLabel.font = .systemFont(ofSize: 80, weight: .regular)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center

        // 레이블 컨테이너 설정
        labelContainerView.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
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
        nameTextField.placeholder = "타이머"
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
        selectedMusicLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(musicLabelTapped))
        selectedMusicLabel.addGestureRecognizer(tapGesture)
        
        musicContainerView.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        musicContainerView.layer.cornerRadius = 8
        musicContainerView.clipsToBounds = true
        
        // 컨트롤 버튼 설정
        setupControlButton(resetButton, systemName: "arrow.counterclockwise")
        setupControlButton(playPauseButton, systemName: "play.fill")
        resetButton.backgroundColor = UIColor(red: 72/255, green: 144/255, blue: 216/255, alpha: 1)
        playPauseButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        // 최근 항목 레이블 설정
        recentLabel.text = "최근 항목"
        recentLabel.font = .systemFont(ofSize: 20, weight: .bold)
        recentLabel.textColor = .white
        
        // 컴포넌트 추가
        [timerLabel, timePickerView, labelContainerView, resetButton, playPauseButton,
         recentLabel, recentTableView, musicContainerView].forEach {
            view.addSubview($0)
        }
        
        labelContainerView.addSubview(labelTextLabel)
        labelContainerView.addSubview(nameTextField)
        musicContainerView.addSubview(timerEndButton)
        musicContainerView.addSubview(selectedMusicLabel)
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
    
    private func setupConstraints() {
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        timePickerView.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        
        labelContainerView.snp.makeConstraints { make in
            make.top.equalTo(timePickerView.snp.bottom).offset(20)
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
            make.width.greaterThanOrEqualTo(100)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(musicContainerView.snp.bottom).offset(20)
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
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }

        selectedMusicLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(timerEndButton.snp.trailing).offset(10)
        }
        
        recentTableView.snp.makeConstraints { make in
            make.top.equalTo(recentLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setupPickerView() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        timePickerView.selectRow(viewModel.hours, inComponent: 0, animated: false)
        timePickerView.selectRow(viewModel.minutes, inComponent: 1, animated: false)
        timePickerView.selectRow(viewModel.seconds, inComponent: 2, animated: false)
    }
    
    // MARK: - Button Actions
    @objc private func resetButtonTapped() {
        viewModel.resetTimer()
        nameTextField.text = ""
    }
    
    @objc private func musicLabelTapped() {
        presentMusicSelectViewController()
    }

    @objc private func timerEndButtonTapped() {
        presentMusicSelectViewController()
    }
    
    @objc private func playPauseButtonTapped() {
        if viewModel.hours == 0 && viewModel.minutes == 0 && viewModel.seconds == 0 {
            return
        }
        if !viewModel.isRunning {
            let name = nameTextField.text?.isEmpty == true ? "타이머" : nameTextField.text!
            viewModel.startTimer(withName: name)
        } else {
            viewModel.stopTimer()
        }
    }
    
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

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension TimerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hourArray.count
        case 1: return minuteArray.count
        case 2: return secondArray.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value: Int
        let suffix: String
        
        switch component {
        case 0:
            guard row < hourArray.count else { return nil }
            value = hourArray[row]
            suffix = "시간"
        case 1:
            guard row < minuteArray.count else { return nil }
            value = minuteArray[row]
            suffix = "분"
        case 2:
            guard row < secondArray.count else { return nil }
            value = secondArray[row]
            suffix = "초"
        default:
            return nil
        }
        
        return "\(value)\(suffix)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            guard row < hourArray.count else { return }
            viewModel.setTimer(hours: hourArray[row],
                             minutes: viewModel.minutes,
                             seconds: viewModel.seconds)
        case 1:
            guard row < minuteArray.count else { return }
            viewModel.setTimer(hours: viewModel.hours,
                             minutes: minuteArray[row],
                             seconds: viewModel.seconds)
        case 2:
            guard row < secondArray.count else { return }
            viewModel.setTimer(hours: viewModel.hours,
                             minutes: viewModel.minutes,
                             seconds: secondArray[row])
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
           guard let title = self.pickerView(pickerView, titleForRow: row, forComponent: component) else {
               return nil
           }
           
           return NSAttributedString(string: title, attributes: [
               .foregroundColor: UIColor.white,
               .font: UIFont.systemFont(ofSize: 18)
           ])
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

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let timer = viewModel.timerItems[indexPath.row]

       viewModel.setTimer(hours: timer.hours,
                         minutes: timer.minutes,
                         seconds: timer.seconds)
       
       nameTextField.text = timer.name
       tableView.deselectRow(at: indexPath, animated: true)
   }
   
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
   }
   
   func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
           self?.viewModel.deleteTimer(at: indexPath.row)
           completion(true)
       }
       
       return UISwipeActionsConfiguration(actions: [deleteAction])
   }
}

// MARK: - MusicSelectViewControllerDelegate
extension TimerView: MusicSelectViewControllerDelegate {
   func didSelectMusic(_ music: MusicModel) {
       selectedMusicLabel.text = music.name
       viewModel.setSelectedMusic(music)
   }
}

extension TimerView: TimerViewModelDelegate {
    func showAlertViewController() {
        DispatchQueue.main.async { [weak self] in
            let alertVC = AlertViewController()
            alertVC.modalPresentationStyle = .fullScreen
            alertVC.delegate = self
            self?.present(alertVC, animated: true, completion: nil)
        }
    }
}

extension TimerView: AlertViewControllerDelegate {
    func alertViewControllerDidDismiss() {
        viewModel.stopTimerAndAudio()
    }
    
    func alertViewControllerDidRequestSnooze(minutes: Int) {
        viewModel.setSnoozeTimer(snoozeMinutes: minutes)
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
