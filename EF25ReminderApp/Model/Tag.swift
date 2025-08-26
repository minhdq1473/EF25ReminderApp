//
//  Tag.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//
import UIKit

enum Tag: String, CaseIterable {
    case study = "Study"
    case work = "Work"
    case habit = "Habit"
    case health = "Health"
    
    var uiColor: UIColor {
        switch self {
        case .study: return .accent
        case .work: return .warning
        case .habit: return .low
        case .health: return .primary1
        }
    }
}
