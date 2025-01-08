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
        //TIL
        //let navigationItem = UINavigationItem(title:"home")
        //self.title = "Home"
        
        //편집버튼 설정
        let editBtn = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editBtnTapped))
        // 타이틀 폰트 크기 및 색상 설정
        let leftAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20), // 폰트 크기 설정
            .foregroundColor: UIColor.green         // 텍스트 색상 설정
        ]
        editBtn.setTitleTextAttributes(leftAttributes, for: .normal)
        navigationItem.leftBarButtonItem = editBtn
        
        //+버튼 설정
        let addBtn = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addBtnTapped))
        // 타이틀 폰트 크기 및 색상 설정
        let rightAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30), // 폰트 크기 설정
            .foregroundColor: UIColor.green         // 텍스트 색상 설정
        ]
        addBtn.setTitleTextAttributes(rightAttributes, for: .normal)
        navigationItem.rightBarButtonItem = addBtn
    
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
        present(ModalTestVC(), animated: true, completion: nil)
    }
    @objc func editBtnTapped() {
        present(ModalTestVC(), animated: true, completion: nil)
    }

}

