//
//  MusicSelectViewController.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/10/25.
//

import UIKit
import AVFoundation
import SnapKit

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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "알림음 선택"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(MusicSelectCell.self, forCellReuseIdentifier: "MusicCell")
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    private lazy var silentButton: UIButton = {
        let button = UIButton()
        button.setTitle("무음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 16)
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
        view.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 38/255, alpha: 1)
        
        [cancelButton, settingButton, titleLabel, tableView, silentButton].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(cancelButton)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
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

// MARK: - MusicSelectCell
class MusicSelectCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "checkmark")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkmarkImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func configure(with music: MusicModel) {
        titleLabel.text = music.name
        checkmarkImageView.isHidden = !music.isSelected
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MusicSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as? MusicSelectCell else {
            return UITableViewCell()
        }
        let music = musicList[indexPath.row]
        cell.configure(with: music)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
