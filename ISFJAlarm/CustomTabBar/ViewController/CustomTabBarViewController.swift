//
//  CustomTabBarViewController.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/8/25.
//

import UIKit
import SnapKit

class CustomTabBarController: UIViewController {
    private let tabBarView = CustomTabBarView()
    private let viewModel = TabBarViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(tabBarView)

        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(60)
        }
    }

    private func bindViewModel() {
        tabBarView.onTabSelected = { [weak self] index in
            self?.viewModel.selectTab(at: index)
        }

        viewModel.onTabChanged = { [weak self] index in
            self?.handleTabChange(index)
        }
    }

    private func handleTabChange(_ index: Int) {
        print("Selected Tab Index: \(index)")
        // 선택된 탭에 따라 화면 전환 추가 가능
    }
}
