//
//  Untitled.swift
//  ISFJEditor
//
//  Created by Jimin on 1/8/25.
//

import UIKit
import AVFoundation
import SnapKit

protocol SoundViewControllerDelegate: AnyObject {
    func didSelectSound(_ sound: String)
}

class SoundViewController: UIViewController {
    
    weak var delegate: SoundViewControllerDelegate?
    private var audioPlayer: AVAudioPlayer?
    private var musicList: [MusicModel] = []
    private let currentSelectedSound: String
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MusicCell")
        return table
    }()
    
    init(selectedSound: String) {
        self.currentSelectedSound = selectedSound
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMusicList()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "사운드"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadMusicList() {
        
        // 기본 "무음" 옵션 추가
        var list = [MusicModel(name: "무음", filename: "", isSelected: currentSelectedSound == "무음")]
        
        // 나머지 음악 목록 추가
        let musics = [
            MusicModel(name: "Adeles Oath Infinite", filename: "Adeles Oath Infinite.mp3", isSelected: false),
            MusicModel(name: "Life is Full of Happiness", filename: "Life is Full of Happiness.mp3", isSelected: false),
            MusicModel(name: "Raindrop Flower", filename: "Raindrop Flower.mp3", isSelected: false),
            MusicModel(name: "Riding on the Clouds", filename: "Riding on the Clouds.mp3", isSelected: false),
            MusicModel(name: "Romantic Sunset", filename: "Romantic Sunset.mp3", isSelected: false),
            MusicModel(name: "When the Morning Comes", filename: "When the Morning Comes.mp3", isSelected: false)
        ]
        
        list.append(contentsOf: musics)
        
        // 현재 선택된 사운드에 체크마크 표시
        list = list.map { music in
            var updatedMusic = music
            updatedMusic.isSelected = (music.name == currentSelectedSound)
            return updatedMusic
        }
        
        musicList = list
        tableView.reloadData()
    }
    
    private func playMusic(_ music: MusicModel) {
        guard music.name != "무음" else {
            audioPlayer?.stop()
            return
        }
        
        audioPlayer?.stop()
        
        guard let path = Bundle.main.path(forResource: music.name, ofType: "mp3") else {
            print("음악 파일을 찾을 수 없습니다: \(music.name)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("음악 재생 실패: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
        
        // 선택된 음악 정보 전달
        if let selectedMusic = musicList.first(where: { $0.isSelected }) {
            delegate?.didSelectSound(selectedMusic.name)
        }
    }
}

// MARK: - extension
extension SoundViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        let music = musicList[indexPath.row]
        
        cell.textLabel?.text = music.name
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .darkGray
        cell.accessoryType = music.isSelected ? .checkmark : .none
        cell.tintColor = .orange
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMusic = musicList[indexPath.row]
        playMusic(selectedMusic)
        
        // 이전에 선택된 셀의 체크마크 제거
        musicList.indices.forEach { index in
            musicList[index].isSelected = (index == indexPath.row)
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
