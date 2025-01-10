//
//  MusicSelectViewController.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/10/25.
//

import UIKit
import AVFoundation

class MusicSelectViewController: UIViewController {
    private var audioPlayer: AVAudioPlayer?
    private var selectedMusic: MusicModel?
    private var musicList: [MusicModel] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMusicList()
    }
    
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
        if let resourcePath = Bundle.main.resourcePath {
            print("Resource Path: \(resourcePath)")
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("All bundle items: \(items)")
                
                // MP3 파일만 필터링
                musicList = items
                    .filter { $0.hasSuffix(".mp3") }
                    .map { filename in
                        MusicModel(
                            name: filename.replacingOccurrences(of: ".mp3", with: ""),
                            filename: filename,
                            isSelected: false
                        )
                    }
                
                print("Found music files: \(musicList)")
                tableView.reloadData()
            } catch {
                print("음악 파일 로드 실패: \(error)")
                print("Error details: \(error.localizedDescription)")
            }
        } else {
            print("리소스 경로를 찾을 수 없습니다.")
        }
    }
    
    private func playMusic(_ music: MusicModel) {
        print("재생 시도: \(music.name)")  // 디버깅용 로그
        
        // 기존 재생 중인 음악 중지
        audioPlayer?.stop()
        
        // 파일 경로 확인
        guard let path = Bundle.main.path(forResource: music.name, ofType: "mp3") else {
            print("음악 파일을 찾을 수 없습니다: \(music.name)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        print("음악 파일 경로: \(url)")  // 디버깅용 로그
        
        do {
            // AVAudioSession 설정
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 오디오 플레이어 초기화 및 재생
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("재생 시작됨")  // 디버깅용 로그
        } catch {
            print("음악 재생 실패: \(error.localizedDescription)")
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func settingButtonTapped() {
        // 선택된 음악 저장 및 모달 닫기
        dismiss(animated: true)
    }
    
    @objc private func silentButtonTapped() {
        audioPlayer?.stop()
        selectedMusic = MusicModel.defaultMusic()
        dismiss(animated: true)
    }
}

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
        print("선택된 음악: \(selectedMusic.name)")  // 디버깅용 로그
        playMusic(selectedMusic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
