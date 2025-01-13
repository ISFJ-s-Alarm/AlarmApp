//
//  TimerModel.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/9/25.
//

import Foundation

struct TimerModel {
    let id = UUID()
    var name: String
    var hours: Int
    var minutes: Int
    var seconds: Int
    var createdAt: Date
    var selectedMusic: String?  // 음악이 없을수도 있기에 옵셔널 설정
    
    // formattedTime 연산 프로퍼티 추가
    var formattedTime: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    static func fromTimerItem(_ item: TimerItem) -> TimerModel {
        return TimerModel(
            name: item.name ?? "Unknown",
            hours: Int(item.hours),
            minutes: Int(item.minutes),
            seconds: Int(item.seconds),
            createdAt: item.createdAt ?? Date(),
            selectedMusic: item.selectedMusic
        )
    }
}
