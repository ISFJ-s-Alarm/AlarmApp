//
//  MusicModel.swift
//  ISFJAlarm
//
//  Created by 유태호 on 1/10/25.
//

import Foundation

struct MusicModel {
    let id = UUID()
    var name: String
    var filename: String
    var isSelected: Bool
    
    static func defaultMusic() -> MusicModel {
        return MusicModel(name: "무음", filename: "", isSelected: true)
    }
}
