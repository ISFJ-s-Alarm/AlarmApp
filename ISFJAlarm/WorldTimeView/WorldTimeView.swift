//
//  WorldTimeView.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/14/25.
//
import UIKit
import SnapKit

class WorldTimeView: UIViewController {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let addButton = UIButton()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private var cities: [String] = []  // 도시 목록을 저장할 배열
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateEmptyState()
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
        // 타이틀 레이블 설정
        titleLabel.text = "세계 시계"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        // 추가 버튼 설정
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .orange
        
        // 테이블뷰 설정
        tableView.backgroundColor = .clear
        
        // 빈 상태 레이블 설정
        emptyStateLabel.text = "세계 시계 없음"
        emptyStateLabel.textColor = .gray
        emptyStateLabel.font = .systemFont(ofSize: 17)
        emptyStateLabel.textAlignment = .center
        
        // 컴포넌트 추가
        [titleLabel, addButton, tableView, emptyStateLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50) // 탭바 공간 확보
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WorldTimeCell.self, forCellReuseIdentifier: WorldTimeCell.identifier)
        tableView.separatorStyle = .none
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !cities.isEmpty
        tableView.isHidden = cities.isEmpty
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WorldTimeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorldTimeCell.identifier, for: indexPath) as? WorldTimeCell else {
            return UITableViewCell()
        }
        
        let city = cities[indexPath.row]
        cell.configure(city: city, time: "오전 1:58", timeDiff: "-14시간")  // 시간 정보는 실제 구현 필요
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90  // 셀 높이 조정
    }
}

// MARK: - WorldTimeCell
class WorldTimeCell: UITableViewCell {
    static let identifier = "WorldTimeCell"
    
    private let cityLabel = UILabel()
    private let timeLabel = UILabel()
    private let timeDiffLabel = UILabel()
    
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
        
        cityLabel.textColor = .white
        cityLabel.font = .systemFont(ofSize: 24)
        
        timeDiffLabel.textColor = .white
        timeDiffLabel.font = .systemFont(ofSize: 15)
        
        timeLabel.textColor = .white
        timeLabel.font = .systemFont(ofSize: 48)
        timeLabel.textAlignment = .right
        
        [cityLabel, timeDiffLabel, timeLabel].forEach {
            contentView.addSubview($0)
        }
        
        cityLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
        }
        
        timeDiffLabel.snp.makeConstraints { make in
            make.leading.equalTo(cityLabel)
            make.top.equalTo(cityLabel.snp.bottom).offset(4)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(city: String, time: String, timeDiff: String) {
        cityLabel.text = city
        timeLabel.text = time
        timeDiffLabel.text = "오늘, \(timeDiff)"
    }
}

@available(iOS 17.0, *)
#Preview {
    WorldTimeView()
}
