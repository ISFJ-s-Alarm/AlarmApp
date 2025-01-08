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

    init(titles: [String]) {
        super.init(frame: .zero)
        setupUI(titles: titles)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(titles: [String]) {
        self.backgroundColor = .black

        for (index, title) in titles.enumerated() {
            // 버튼 배경 뷰 생성
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            backgroundView.layer.cornerRadius = 30
            self.insertSubview(backgroundView, at: 0)
            backgroundViews.append(backgroundView)

            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            button.tag = index
            button.setTitleColor(.white, for: .normal)
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
            backgroundViews[index].frame = buttonFrame
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        updateButtonSelection(selectedIndex: sender.tag)
        onTabSelected?(sender.tag)
    }

    private func updateButtonSelection(selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                backgroundViews[index].backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                button.setTitleColor(.white, for: .normal)
            } else {
                backgroundViews[index].backgroundColor = .clear
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
}
