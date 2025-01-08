//
//  ViewController.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/7/25.
//

import UIKit

import SnapKit
import Then

class ViewController: UIViewController {

    
    //MARK: UI요소
    private let alarmLabel = UILabel().then {
        $0.text = "알람"
        $0.textAlignment = .left
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
    }
    
    //MARK: navigationBar
    private func navigationBar() {
        //생성
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        
        //let navigationItem = UINavigationItem(title:"home")
        let addBtn = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addBtnTapped))
        navigationItem.rightBarButtonItem = addBtn
        
        let editBtn = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editBtnTapped))
        navigationItem.leftBarButtonItem = editBtn
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    //MARK: UI 정의
    private func configureUI() {
        navigationBar()
        view.backgroundColor = .black
        
        view.addSubview(alarmLabel)
        alarmLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
    }

    //MARK: Button Actions
    @objc
    private func addBtnTapped() {
        
    }
    @objc func editBtnTapped() {
        
    }

}

