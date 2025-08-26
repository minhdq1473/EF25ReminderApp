//
//  Tag.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//
import UIKit
import RealmSwift

class Tag: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var color: TagColor = .systemBlue

    var uiColor: UIColor { color.uiColor }

    convenience init(name: String, color: TagColor) {
        self.init()
        self.name = name
        self.color = color
    }
}

enum TagColor: String, PersistableEnum {
    case study
    case work
    case habit
    case health
    case systemBlue
    case systemOrange
    case systemGreen
    case systemPurple
    case systemRed
    case systemTeal

    var uiColor: UIColor {
        switch self {
        case .study: return .accent
        case .work: return .warning
        case .habit: return .low
        case .health: return .primary1
        case .systemBlue: return .systemBlue
        case .systemOrange: return .systemOrange
        case .systemGreen: return .systemGreen
        case .systemPurple: return .systemPurple
        case .systemRed: return .systemRed
        case .systemTeal: return .systemTeal
        }
    }
}
