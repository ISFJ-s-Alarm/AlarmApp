//
//  CustomTabBarViewController.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/8/25.
//
import UIKit
import SnapKit

/// 커스텀 탭바 컨트롤러
class CustomTabBarController: UIViewController {
    private let tabBarView = CustomTabBarView() // 커스텀 탭 바

    // 화면별 뷰 컨트롤러
    private let timerVC = UINavigationController(rootViewController: TimerView())
    private let stopwatchVC = UINavigationController(rootViewController: StopwatchViewController())
    private let alarmVC = UINavigationController(rootViewController: ViewController())

    // 현재 활성화된 뷰 컨트롤러
    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTabBarActions()
        switchToViewController(alarmVC) // 초기 화면 설정
    }

    /// UI 구성
    private func setupUI() {
        view.backgroundColor = .white

        // 커스텀 탭바 추가
        view.addSubview(tabBarView)
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(80)
        }
    }

    /// 탭바 버튼 동작 설정
    private func setupTabBarActions() {
        tabBarView.onTabSelected = { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 0: self.switchToViewController(self.alarmVC)
            case 1: self.switchToViewController(self.stopwatchVC)
            case 2: self.switchToViewController(self.timerVC)
            default: break
            }
        }
    }

    /// 현재 뷰 컨트롤러 전환
    /// - Parameter newViewController: 새로 활성화할 뷰 컨트롤러
    private func switchToViewController(_ newViewController: UIViewController) {
        // 이전 뷰 컨트롤러 제거
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        // 새 뷰 컨트롤러 추가
        addChild(newViewController)
        view.insertSubview(newViewController.view, belowSubview: tabBarView) // 탭바 아래에 추가
        newViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview() // 전체 화면에 꽉 차도록 설정
        }
        newViewController.didMove(toParent: self)

        currentViewController = newViewController // 현재 뷰 컨트롤러 업데이트
    }
}
