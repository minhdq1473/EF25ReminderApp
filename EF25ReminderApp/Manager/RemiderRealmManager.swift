//
//  RemiderRealmManager.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//
import RealmSwift

class ReminderRealmManager {
    static let shared = ReminderRealmManager()
    private let realm: Realm
    
    private init() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: Reminder.className()) { oldObject, newObject in
                            newObject!["createdAt"] = Date()
                        }
                    }
                }
            )
            Realm.Configuration.defaultConfiguration = config
            
            realm = try Realm()
            seedDefaultTagsIfNeeded()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        do {
            try realm.write {
                realm.add(reminder)
            }
        } catch {
            print("Error adding reminder: \(error)")
        }
    }
    
    func updateReminder(_ reminder: Reminder) {
        do {
            try realm.write {
                realm.add(reminder, update: .modified)
            }
        } catch {
            print("Error updating reminder: \(error)")
        }
    }
    
    func deleteReminder(withId id: ObjectId) {
        do {
            if let reminder = realm.object(ofType: Reminder.self, forPrimaryKey: id) {
                try realm.write {
                    realm.delete(reminder)
                }
            }
        } catch {
            print("Error deleting reminder: \(error)")
        }
    }
    
    func getAllReminders() -> [Reminder] {
        return Array(realm.objects(Reminder.self))
    }
    
    func getTodayReminders() -> [Reminder] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return getAllReminders().filter { reminder in
            guard let dueDate = reminder.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow
        }
    }
    
    func getUpcomingReminders() -> [Reminder] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        
        return getAllReminders().filter { reminder in
            guard let dueDate = reminder.dueDate else { return false }
            return dueDate >= tomorrow
        }
    }
    
    func getRemindersByTag(_ tag: Tag) -> [Reminder] {
        return getAllReminders().filter { reminder in
            reminder.tags.contains(where: { $0.id == tag.id })
        }
    }
    
    func observeAllReminders(_ onChange: @escaping ([Reminder]) -> Void) -> NotificationToken? {
        let results = realm.objects(Reminder.self)
        onChange(Array(results))
        let token = results.observe { _ in
            onChange(Array(results))
        }
        return token
    }
    
    func getAllTags() -> [Tag] {
        let tags = Array(realm.objects(Tag.self))
        print("getAllTags returned \(tags.count) tags: \(tags.map { $0.name })")
        return tags
    }
    
    func addTag(_ tag: Tag) {
        do {
            try realm.write {
                realm.add(tag)
            }
        } catch {
            print("Error adding tag: \(error)")
        }
    }
    
    func ensureTag(named name: String, colorKey: String) -> Tag {
        if let existing = realm.objects(Tag.self).filter("name == %@", name).first {
            return existing
        }
        let color = TagColor(rawValue: colorKey) ?? .systemBlue
        let tag = Tag(name: name, color: color)
        addTag(tag)
        return tag
    }
    
    private func seedDefaultTagsIfNeeded() {
        let defaults: [(String, TagColor)] = [
            ("Study", .study),
            ("Work", .work),
            ("Habit", .habit),
            ("Health", .health)
        ]
        if realm.objects(Tag.self).count == 0 {
            do {
                try realm.write {
                    for (name, color) in defaults {
                        realm.add(Tag(name: name, color: color))
                    }
                }
                print("Seeded \(defaults.count) default tags")
            } catch {
                print("Seed tags error: \(error)")
            }
        } else {
            print("Tags already exist, count: \(realm.objects(Tag.self).count)")
        }
    }
}
