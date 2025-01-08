//
//  ModalTestVC.swift
//  ISFJAlarm
//
//  Created by 이재건 on 1/8/25.
//

import UIKit

import SnapKit
import Then

class ModalTestVC: ViewController {
    
    let label = UILabel().then {
        $0.text = "모달 띄우기 성공"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
