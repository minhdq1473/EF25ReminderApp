//
//  DetailVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit
import RealmSwift

class DetailVC: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
//    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var tagCell: UIStackView!
    @IBOutlet weak var tagLabel: UILabel!
    var reminder: Reminder?
    private var selectedTags: [Tag] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNav()
        fillIfEditing()
        setupTagCellTap()
        updateTagLabel()
    }

    private func setupNav() {
        title = "New Reminder"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func fillIfEditing() {
        guard let reminder = reminder else { return }
        title = "Edit Reminder"
        titleTextField.text = reminder.title
        descriptionTextField.text = reminder.descriptionText
        if let date = reminder.dueDate {
            dateSwitch.isOn = true
            datePicker.date = date
        } else {
            dateSwitch.isOn = false
        }
        selectedTags = Array(reminder.tags)
    }

    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        datePicker.isHidden = !sender.isOn
    }

    private func setupTagCellTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openTagPicker))
        tagCell.isUserInteractionEnabled = true
        tagCell.addGestureRecognizer(tap)
    }

    @objc private func openTagPicker() {
        let vc = TagVC(nibName: "TagVC", bundle: nil)
        vc.onSelect = { [weak self] tags in
            self?.selectedTags = tags
            self?.updateTagLabel()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

//    private func updateTagButton() {
//        if let tag = selectedTag {
//            tagButton.setTitle(tag.rawValue, for: .normal)
//            tagButton.backgroundColor = tag.color
//            tagButton.setTitleColor(.white, for: .normal)
//            tagButton.layer.cornerRadius = 8
//            tagButton.layer.masksToBounds = true
//        } else {
//            tagButton.setTitle("Tag", for: .normal)
//            tagButton.backgroundColor = .systemGray5
//            tagButton.setTitleColor(.label, for: .normal)
//        }
//    }

    @objc private func cancelTapped() {
        if presentingViewController != nil && navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func doneTapped() {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !titleText.isEmpty else { return }
        let descriptionText = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let dueDate = dateSwitch.isOn ? datePicker.date : nil

        if let editing = reminder {
            do {
                let realm = try Realm()
                try realm.write {
                    editing.title = titleText
                    editing.descriptionText = descriptionText
                    editing.dueDate = dueDate
                    editing.tags.removeAll()
                    editing.tags.append(objectsIn: selectedTags)
                }
            } catch {
                print("Save error: \(error)")
            }
        } else {
            let newItem = Reminder(title: titleText, descriptionText: descriptionText, dueDate: dueDate, tags: selectedTags)
            ReminderRealmManager.shared.addReminder(newItem)
        }
        navigationController?.popViewController(animated: true)
    }

    private func updateTagLabel() {
        if selectedTags.isEmpty {
            tagLabel.text = "None"
            tagLabel.textColor = .secondaryLabel
        } else {
            tagLabel.text = selectedTags.map { $0.name }.joined(separator: ", ")
            tagLabel.textColor = .label
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
