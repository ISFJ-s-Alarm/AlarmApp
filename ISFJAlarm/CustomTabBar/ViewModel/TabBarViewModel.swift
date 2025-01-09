//
//  TabBarViewModel.swift
//  ISFJAlarm
//
//  Created by t2023-m0149 on 1/8/25.
//

import Foundation

class TabBarViewModel {
    private(set) var selectedIndex: Int = 0 {
        didSet {
            onTabChanged?(selectedIndex)
        }
    }

    var onTabChanged: ((Int) -> Void)?

    func selectTab(at index: Int) {
        selectedIndex = index
        onTabChanged?(index)
    }
}
