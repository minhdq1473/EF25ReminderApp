//
//  HomeVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var reminderList: UITableView!
    
    private var reminders: [Reminder] = []
//    private var notificationToken: NotificationToken?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupBtn()
//        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reminderList.reloadData()
        setupEmptyView()
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        let vc = DetailVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupNavigationBar() {
        title = "Reminders"
        
        let sortBtn = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(sortBtnTapped))
        
        navigationItem.rightBarButtonItem = sortBtn
    }
    
    @objc private func sortBtnTapped() {
        
    }
    
    private func setupEmptyView() {
        if reminders.isEmpty {
            emptyLabel.isHidden = false
            reminderList.isHidden = true
        } else {
            emptyLabel.isHidden = true
            reminderList.isHidden = false
        }
    }
    
    private func setupTableView() {
        reminderList.delegate = self
        reminderList.dataSource = self
        reminderList.register(UINib(nibName: "ReminderCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
    }
    
    private func setupBtn() {
        addBtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
    }
    
//    private func bindData() {
//        notificationToken = ReminderRealmManager.shared.observeAllReminders { [weak self] list in
//            self?.reminders = list.sorted(by: { lhs, rhs in
//                let l = lhs.dueDate ?? .distantFuture
//                let r = rhs.dueDate ?? .distantFuture
//                return l < r
//            })
//            self?.setupEmptyView()
//            self?.reminderList.reloadData()
//        }
//    }
//    
//    deinit {
//        notificationToken?.invalidate()
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as? ReminderCell else {
            return UITableViewCell()
        }
        let item = reminders[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailVC(nibName: "DetailVC", bundle: nil)
        vc.reminder = reminders[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            let id = self.reminders[indexPath.row].id
            ReminderRealmManager.shared.deleteReminder(withId: id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
