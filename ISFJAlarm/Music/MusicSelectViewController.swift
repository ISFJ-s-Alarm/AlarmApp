//
//  MusicSelectViewController.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/10/25.
//

import UIKit
import AVFoundation

protocol MusicSelectViewControllerDelegate: AnyObject {
    func didSelectMusic(_ music: MusicModel)
}

class MusicSelectViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: MusicSelectViewControllerDelegate?
    private var audioPlayer: AVAudioPlayer?
    private var currentSelectedMusic: MusicModel?
    private var musicList: [MusicModel] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MusicCell")
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        return button
    }()
    
    private lazy var silentButton: UIButton = {
        let button = UIButton()
        button.setTitle("실행 중단", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMusicList()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(settingButton)
        view.addSubview(tableView)
        view.addSubview(silentButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(silentButton.snp.top).offset(-20)
        }
        
        silentButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        silentButton.addTarget(self, action: #selector(silentButtonTapped), for: .touchUpInside)
    }
    
    private func loadMusicList() {
        // 하드코딩된 음악 리스트 (실제로는 Bundle에서 로드)
        musicList = [
            MusicModel(name: "Adeles Oath Infinite", filename: "Adeles Oath Infinite.mp3", isSelected: false),
            MusicModel(name: "Life is Full of Happiness", filename: "Life is Full of Happiness.mp3", isSelected: false),
            MusicModel(name: "Raindrop Flower", filename: "Raindrop Flower.mp3", isSelected: false),
            MusicModel(name: "Riding on the Clouds", filename: "Riding on the Clouds.mp3", isSelected: false),
            MusicModel(name: "Romantic Sunset", filename: "Romantic Sunset.mp3", isSelected: false),
            MusicModel(name: "When the Morning Comes", filename: "When the Morning Comes.mp3", isSelected: false)
        ]
        tableView.reloadData()
    }
    
    private func playMusic(_ music: MusicModel) {
        print("재생 시도: \(music.name)")
        
        audioPlayer?.stop()
        
        guard let path = Bundle.main.path(forResource: music.name, ofType: "mp3") else {
            print("음악 파일을 찾을 수 없습니다: \(music.name)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        print("음악 파일 경로: \(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("재생 시작됨")
        } catch {
            print("음악 재생 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Button Actions
    @objc private func cancelButtonTapped() {
        audioPlayer?.stop()
        dismiss(animated: true)
    }
    
    @objc private func settingButtonTapped() {
        if let selectedMusic = currentSelectedMusic {
            delegate?.didSelectMusic(selectedMusic)
        }
        audioPlayer?.stop()
        dismiss(animated: true)
    }
    
    @objc private func silentButtonTapped() {
        audioPlayer?.stop()
        delegate?.didSelectMusic(MusicModel.defaultMusic())
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MusicSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        let music = musicList[indexPath.row]
        
        cell.textLabel?.text = music.name
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.accessoryType = music.isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMusic = musicList[indexPath.row]
        currentSelectedMusic = selectedMusic
        playMusic(selectedMusic)
        
        // 이전에 선택된 셀의 체크마크 제거
        musicList.indices.forEach { index in
            musicList[index].isSelected = (index == indexPath.row)
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
