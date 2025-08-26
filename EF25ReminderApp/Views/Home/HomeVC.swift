//
//  HomeVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit
import RealmSwift

class HomeVC: UIViewController {
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var reminderList: UITableView!
    
    private var allReminders: [Reminder] = []
    private var todayReminders: [Reminder] = []
    private var upcomingReminders: [Reminder] = []
    private var isSearching = false
    private var isAddingInline = false
    private var currentSortOption: SortOption = .creationDate
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotifications()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupEmptyView()
    }
    
    private func setupUI() {
        title = "Reminders"
        setupNavigationBar()
        setupTableView()
        setupSearchBar()
    }
    
    private func setupNavigationBar() {
        let sortBtn = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortBtnTapped))
        navigationItem.rightBarButtonItem = sortBtn
    }
    
    private func setupTableView() {
        reminderList.delegate = self
        reminderList.dataSource = self
        reminderList.register(UINib(nibName: "ReminderCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .neutral7
        
        let leftSearchView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 20))
        icon.frame = CGRect(x: 6, y: 0, width: 20, height: 20)
        leftSearchView.addSubview(icon)
        
        searchBar.leftView = leftSearchView
        searchBar.leftViewMode = .always
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    private func loadData() {
        notificationToken = ReminderRealmManager.shared.observeAllReminders { [weak self] reminders in
            DispatchQueue.main.async {
                self?.allReminders = reminders
                self?.categorizeReminders()
                self?.applySorting()
                self?.setupEmptyView()
                self?.reminderList.reloadData()
            }
        }
    }
    
    private func categorizeReminders() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        todayReminders = allReminders.filter { reminder in
            guard let dueDate = reminder.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow
        }
        
        upcomingReminders = allReminders.filter { reminder in
            guard let dueDate = reminder.dueDate else { return false }
            return dueDate >= tomorrow
        }
    }
    
    private func applySorting() {
        switch currentSortOption {
        case .creationDate:
            todayReminders.sort { $0.createdAt > $1.createdAt }
            upcomingReminders.sort { $0.createdAt > $1.createdAt }
        case .title:
            todayReminders.sort { $0.title.lowercased() < $1.title.lowercased() }
            upcomingReminders.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .dueDate:
            todayReminders.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            upcomingReminders.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        }
    }
    
    private func applySearch() {
        if isSearching, let searchText = searchBar.text, !searchText.isEmpty {
            let filtered = allReminders.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                ($0.descriptionText?.lowercased().contains(searchText.lowercased()) ?? false)
            }
            
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            todayReminders = filtered.filter { reminder in
                guard let dueDate = reminder.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }
            
            upcomingReminders = filtered.filter { reminder in
                guard let dueDate = reminder.dueDate else { return false }
                return dueDate >= tomorrow
            }
        } else {
            categorizeReminders()
        }
    }
    
    private func setupEmptyView() {
        let hasReminders = todayReminders.count > 0 || upcomingReminders.count > 0 || isAddingInline
        emptyLabel.isHidden = hasReminders
        reminderList.isHidden = !hasReminders
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        guard !isAddingInline else { return }
        
        isAddingInline = true
        setupEmptyView()
        
        reminderList.beginUpdates()
        reminderList.insertRows(at: [IndexPath(row: upcomingReminders.count, section: 1)], with: .automatic)
        reminderList.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: self.upcomingReminders.count, section: 1)
            if let cell = self.reminderList.cellForRow(at: indexPath) as? ReminderCell {
                cell.focusOnTitle()
            }
        }
    }
    
    @objc private func sortBtnTapped() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.rawValue, style: .default) { [weak self] _ in
                self?.currentSortOption = option
                self?.applySorting()
                self?.applySearch()
                self?.reminderList.reloadData()
            }
            if option == currentSortOption {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    @objc private func textFieldDidBeginEditing(_ notification: Notification) {
        if let textField = notification.object as? UITextField,
           textField != searchBar {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingTapped))
        }
    }
    
    @objc private func textFieldDidEndEditing(_ notification: Notification) {
        if let textField = notification.object as? UITextField,
           textField != searchBar {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.isAnyTextFieldEditing() {
                    self.setupNavigationBar()
                }
            }
        }
    }
    
    @objc private func doneEditingTapped() {
        for cell in reminderList.visibleCells {
            if let reminderCell = cell as? ReminderCell {
                if reminderCell.titleTF.isFirstResponder || reminderCell.descTF.isFirstResponder {
                    reminderCell.saveIfEditing()
                    break
                }
            }
        }
        view.endEditing(true)
    }
    
    private func isAnyTextFieldEditing() -> Bool {
        for cell in reminderList.visibleCells {
            if let reminderCell = cell as? ReminderCell {
                if reminderCell.titleTF.isFirstResponder || reminderCell.descTF.isFirstResponder {
                    return true
                }
            }
        }
        return false
    }
    
    @objc private func searchTextChanged() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.3)
    }
    
    @objc private func performSearch() {
        isSearching = !((searchBar.text ?? "").isEmpty)
        applySearch()
        setupEmptyView()
        reminderList.reloadData()
    }
    
    private func cancelInlineAdding() {
        guard isAddingInline else { return }
        
        isAddingInline = false
        reminderList.beginUpdates()
        reminderList.deleteRows(at: [IndexPath(row: upcomingReminders.count, section: 1)], with: .automatic)
        reminderList.endUpdates()
        setupEmptyView()
    }
    
    private func saveNewReminder(title: String, description: String?) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            cancelInlineAdding()
            return
        }
        
        let dueDate = Calendar.current.startOfDay(for: Date())
        let reminder = Reminder(title: trimmedTitle, descriptionText: description?.trimmingCharacters(in: .whitespacesAndNewlines), dueDate: dueDate)
        ReminderRealmManager.shared.addReminder(reminder)
        
        isAddingInline = false
        setupNavigationBar()
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        ReminderRealmManager.shared.deleteReminder(withId: reminder.id)
    }
    
    deinit {
        notificationToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todayReminders.count
        } else {
            return upcomingReminders.count + (isAddingInline ? 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return todayReminders.isEmpty ? nil : "Today"
        } else {
            return (upcomingReminders.isEmpty && !isAddingInline) ? nil : "Upcoming"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            let reminder = todayReminders[indexPath.row]
            cell.configureInteractive(with: reminder, onInfoTapped: { [weak self] title, desc in
                self?.presentDetailVC(with: reminder)
            }, onDelete: { [weak self] in
                self?.deleteReminder(reminder)
            })
        } else {
            if isAddingInline && indexPath.row == upcomingReminders.count {
                cell.configureForNewReminder(
                    onInfoTapped: { [weak self] title, desc in
                        self?.presentDetailVC(title: title, description: desc)
                    },
                    onSubmit: { [weak self] title, desc in
                        self?.saveNewReminder(title: title ?? "", description: desc)
                    }
                )
            } else {
                let reminder = upcomingReminders[indexPath.row]
                cell.configureInteractive(with: reminder, onInfoTapped: { [weak self] title, desc in
                    self?.presentDetailVC(with: reminder)
                }, onDelete: { [weak self] in
                    self?.deleteReminder(reminder)
                })
            }
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if indexPath.section == 0 {
//            presentDetailVC(with: todayReminders[indexPath.row])
//        } else {
//            if !isAddingInline || indexPath.row < upcomingReminders.count {
//                presentDetailVC(with: upcomingReminders[indexPath.row])
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 && isAddingInline && indexPath.row == upcomingReminders.count {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            let reminder: Reminder
            if indexPath.section == 0 {
                reminder = self?.todayReminders[indexPath.row] ?? Reminder(title: "")
            } else {
                reminder = self?.upcomingReminders[indexPath.row] ?? Reminder(title: "")
            }
            self?.deleteReminder(reminder)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func presentDetailVC(with reminder: Reminder) {
        let vc = DetailVC(nibName: "DetailVC", bundle: nil)
        vc.reminder = reminder
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func presentDetailVC(title: String?, description: String?) {
        let vc = DetailVC(nibName: "DetailVC", bundle: nil)
        vc.initialTitle = title ?? ""
        vc.initialDescription = description ?? ""
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true) { [weak self] in
            self?.cancelInlineAdding()
        }
    }
}
