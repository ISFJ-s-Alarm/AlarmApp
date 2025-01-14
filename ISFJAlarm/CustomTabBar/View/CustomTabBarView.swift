//
//  CustomTabBarView.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/8/25.
//

import UIKit

class CustomTabBarView: UIView {
    private var backgroundViews: [UIView] = []
    private var buttons: [UIButton] = []

    var onTabSelected: ((Int) -> Void)?

    private let icons = ["alarm.fill", "stopwatch.fill", "timer", "globe"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = UIColor(red: 0/255, green: 38/255, blue: 77/255, alpha: 1)
        self.layer.cornerRadius = 40
        self.layer.masksToBounds = true

        for (index, iconName) in icons.enumerated() {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            backgroundView.layer.cornerRadius = 30
            self.insertSubview(backgroundView, at: 0)
            backgroundViews.append(backgroundView)

            let button = UIButton(type: .system)
            let image = UIImage(systemName: iconName)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            self.addSubview(button)
        }

        updateButtonSelection(selectedIndex: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonWidth = self.bounds.width / CGFloat(buttons.count)
        let buttonHeight = self.bounds.height

        for index in buttons.indices {
            let buttonFrame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
            buttons[index].frame = buttonFrame

            // 버튼 배경 뷰는 정중앙에 위치하도록 설정
            let size = buttonHeight * 0.8 // 원형 크기 비율 설정
            backgroundViews[index].frame = CGRect(
                x: buttonFrame.midX - size / 2,
                y: buttonFrame.midY - size / 2,
                width: size,
                height: size
            )
            backgroundViews[index].layer.cornerRadius = size / 2
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        updateButtonSelection(selectedIndex: sender.tag)
        onTabSelected?(sender.tag)
    }

    private func updateButtonSelection(selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                backgroundViews[index].backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
                button.tintColor = .black
            } else {
                backgroundViews[index].backgroundColor = .clear
                button.tintColor = .white 
            }
        }
    }
}
