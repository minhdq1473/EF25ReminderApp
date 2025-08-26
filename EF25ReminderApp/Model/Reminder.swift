//
//  Reminder.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit
import RealmSwift

class Reminder: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var descriptionText: String?
    @Persisted var dueDate: Date?
    @Persisted var createdAt: Date = Date()
    @Persisted var tagRawValues = List<String>() 

    var tags: [Tag] {
        get {
            return tagRawValues.compactMap { Tag(rawValue: $0) }
        }
        set {
            tagRawValues.removeAll()
            tagRawValues.append(objectsIn: newValue.map { $0.rawValue })
        }
    }

    convenience init(title: String, descriptionText: String? = nil, dueDate: Date? = nil, tags: [Tag] = []) {
        self.init()
        self.title = title
        self.descriptionText = descriptionText
        self.dueDate = dueDate
        self.tags = tags
        self.createdAt = Date()
    }
}
