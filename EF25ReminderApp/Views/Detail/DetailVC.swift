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
    @IBOutlet weak var inputCell: UIStackView!
    @IBOutlet weak var inputSeparatorView: UIView!
    
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateCell: UIStackView!
    @IBOutlet weak var dateSeparatorView: UIView!


    @IBOutlet weak var tagCell: UIStackView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var reminder: Reminder?
    var initialTitle: String = ""
    var initialDescription: String = ""
    private var selectedTags: [Tag] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNav()
        setupStackView()
        fillIfEditing()
        setupTagCellTap()
        setupDateSwitch()
        updateTagLabel()
        setupTextFieldValidation()
    }
    
    private func setupStackView() {
        inputCell.layer.cornerRadius = 10
        dateCell.layer.cornerRadius = 10
        tagCell.layer.cornerRadius = 10
        
        
        dateCell.isLayoutMarginsRelativeArrangement = true
        tagCell.isLayoutMarginsRelativeArrangement = true

        dateCell.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tagCell.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    }
    private func setupNav() {
        title = "New Reminder"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        updateDoneButtonState()
    }
    
    private func setupTextFieldValidation() {
        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let titleText = (titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        navigationItem.rightBarButtonItem?.isEnabled = !titleText.isEmpty
    }

    private func fillIfEditing() {
        if let reminder = reminder {
            titleTextField.text = reminder.title
            descriptionTextField.text = reminder.descriptionText
            
            if let date = reminder.dueDate {
                dateSwitch.isOn = true
                datePicker.date = date
                showDatePicker()
            } else {
                dateSwitch.isOn = false
                hideDatePicker()
            }
            selectedTags = Array(reminder.tags)
        } else {
            titleTextField.text = initialTitle.isEmpty ? "New Reminder" : initialTitle
            descriptionTextField.text = initialDescription
            
            dateSwitch.isOn = false
            hideDatePicker()
            datePicker.date = Calendar.current.startOfDay(for: Date())
        }
        updateDoneButtonState()
    }
    
    private func setupDateSwitch() {
        if dateSwitch.isOn {
            showDatePicker()
            dateSeparatorView.isHidden = false
        } else {
            hideDatePicker()
            dateSeparatorView.isHidden = true
        }
    }

    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            showDatePicker()
            dateSeparatorView.isHidden = false
            if datePicker.date < Calendar.current.startOfDay(for: Date()) {
                datePicker.date = Calendar.current.startOfDay(for: Date())
            }
        } else {
            hideDatePicker()
            dateSeparatorView.isHidden = true
        }
    }
    
    private func showDatePicker() {
        datePicker.isHidden = false
        for constraint in datePicker.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = 314
                break
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDatePicker() {
        for constraint in datePicker.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = 0
                break
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.datePicker.isHidden = true
        }
    }

    private func setupTagCellTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openTagPicker))
        tagCell.isUserInteractionEnabled = true
        tagCell.addGestureRecognizer(tap)
    }

    @objc private func openTagPicker() {
        let vc = TagVC(nibName: "TagVC", bundle: nil)
        vc.selectedTags = selectedTags 
        vc.onSelect = { [weak self] tags in
            self?.selectedTags = tags
            self?.updateTagLabel()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !titleText.isEmpty else { return }
        
        let descriptionText = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let dueDate: Date?
        if dateSwitch.isOn {
            dueDate = datePicker.date
        } else {
            dueDate = Calendar.current.startOfDay(for: Date())
        }

        if let editing = reminder {
            do {
                let realm = try Realm()
                try realm.write {
                    editing.title = titleText
                    editing.descriptionText = descriptionText
                    editing.dueDate = dueDate
                    editing.tags = selectedTags
                }
            } catch {
                print("Save error: \(error)")
                return
            }
        } else {
            let newItem = Reminder(title: titleText, descriptionText: descriptionText, dueDate: dueDate, tags: selectedTags)
            ReminderRealmManager.shared.addReminder(newItem)
        }
        
        dismiss(animated: true)
    }

    private func updateTagLabel() {
        if selectedTags.isEmpty {
            tagLabel.text = "None"
            tagLabel.textColor = .secondaryLabel
        } else {
            tagLabel.text = selectedTags.map { $0.rawValue }.joined(separator: ", ")
            tagLabel.textColor = .label
        }
    }
}
