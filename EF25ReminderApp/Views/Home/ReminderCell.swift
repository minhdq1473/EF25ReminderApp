//
//  ReminderCell.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit
import RealmSwift

class ReminderCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var infoBadge: UIButton!
    
    private var reminder: Reminder?
    private var isEditingMode: Bool = false
    private var onInfoTapped: ((String?, String?) -> Void)?
    private var onSubmit: ((String?, String?) -> Void)?
    private var onDelete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        setupBtn()
        setupTextFields()
        setupInfoBadge()
    }
    
    private func setupTextFields() {
        titleTF.delegate = self
        descTF.delegate = self
        titleTF.returnKeyType = .next
        descTF.returnKeyType = .done
        
        titleTF.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        descTF.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        titleTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        descTF.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        
        titleTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let reminder = reminder, !isEditingMode {
            let titleText = titleTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let descText = descTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !titleText.isEmpty {
                do {
                    let realm = try Realm()
                    try realm.write {
                        reminder.title = titleText
                        reminder.descriptionText = descText
                    }
                } catch {
                    print("Error updating reminder: \(error)")
                }
            }
        }
    }
    
    private func setupInfoBadge() {
        infoBadge.addTarget(self, action: #selector(infoBadgeTapped), for: .touchUpInside)
        infoBadge.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoBadge.tintColor = .systemBlue
        infoBadge.isHidden = true // Hidden by default
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        if isEditingMode {
            // Cancel inline editing
            onSubmit?("", "") // Empty strings to cancel
        } else {
            // Mark as completed or delete existing reminder
            if let reminder = reminder {
                // For now, just delete. You can add completion logic later
                onDelete?()
            } else {
                onDelete?()
            }
        }
    }
    
    @IBAction func infoBadgeTapped(_ sender: UIButton) {
        onInfoTapped?(titleTF.text, descTF.text)
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        // Show infoBadge only when text fields are being edited
        if isEditingMode || textField.isFirstResponder {
            infoBadge.isHidden = false
        }
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        // Hide infoBadge when editing ends
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !self.titleTF.isFirstResponder && !self.descTF.isFirstResponder {
                self.infoBadge.isHidden = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTF {
            descTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            saveCurrentValues()
        }
        return true
    }
    
    private func saveCurrentValues() {
        onSubmit?(titleTF.text, descTF.text)
    }
    
    // Public method to save current values (called from HomeVC when Done button is tapped)
    func saveIfEditing() {
        if isEditingMode {
            saveCurrentValues()
        }
    }
    
    private func setupBtn() {
        checkBox.layer.cornerRadius = 11
        checkBox.layer.borderWidth = 2
        checkBox.layer.borderColor = #colorLiteral(red: 0.6117647059, green: 0.6196078431, blue: 0.7254901961, alpha: 1)
    }
    
    func configure(with reminder: Reminder, onDelete: @escaping () -> Void) {
        self.reminder = reminder
        self.isEditingMode = false
        self.onDelete = onDelete
        
        titleTF.text = reminder.title
        descTF.text = reminder.descriptionText
        
        // Configure for display mode
        titleTF.placeholder = ""
        descTF.placeholder = ""
        titleTF.isEnabled = false
        descTF.isEnabled = false
        
        // Show tags in infoBadge if any
        let tagNames = reminder.tags.map { $0.name }
        if tagNames.isEmpty {
            infoBadge.setTitle("", for: .normal)
            infoBadge.backgroundColor = .clear
            infoBadge.setTitleColor(.secondaryLabel, for: .normal)
        } else {
            infoBadge.setTitle(tagNames.joined(separator: ", "), for: .normal)
            infoBadge.backgroundColor = .systemGray6
            infoBadge.setTitleColor(.label, for: .normal)
            infoBadge.layer.cornerRadius = 8
            infoBadge.layer.masksToBounds = true
        }
        
        infoBadge.setImage(nil, for: .normal)
        infoBadge.isHidden = false
    }
    
    func configureInteractive(with reminder: Reminder, onInfoTapped: @escaping (String?, String?) -> Void, onDelete: @escaping () -> Void) {
        self.reminder = reminder
        self.isEditingMode = false
        self.onInfoTapped = onInfoTapped
        self.onDelete = onDelete
        
        titleTF.text = reminder.title
        descTF.text = reminder.descriptionText
        
        // Configure for interactive mode - text fields are enabled
        titleTF.placeholder = "Title"
        descTF.placeholder = "Notes"
        titleTF.isEnabled = true
        descTF.isEnabled = true
        
        // Show tags in infoBadge if any
        let tagNames = reminder.tags.map { $0.name }
        if tagNames.isEmpty {
            infoBadge.setTitle("", for: .normal)
            infoBadge.backgroundColor = .clear
            infoBadge.setTitleColor(.secondaryLabel, for: .normal)
        } else {
            infoBadge.setTitle(tagNames.joined(separator: ", "), for: .normal)
            infoBadge.backgroundColor = .systemGray6
            infoBadge.setTitleColor(.label, for: .normal)
            infoBadge.layer.cornerRadius = 8
            infoBadge.layer.masksToBounds = true
        }
        
        infoBadge.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoBadge.tintColor = .systemBlue
        infoBadge.isHidden = false
    }
    
    func configureForNewReminder(onInfoTapped: @escaping (String?, String?) -> Void, onSubmit: @escaping (String?, String?) -> Void) {
        self.reminder = nil
        self.isEditingMode = true
        self.onInfoTapped = onInfoTapped
        self.onSubmit = onSubmit
        
        titleTF.text = "New Reminder"
        descTF.text = ""
        titleTF.placeholder = "Title"
        descTF.placeholder = "Notes"
        titleTF.isEnabled = true
        descTF.isEnabled = true
        
        // Configure infoBadge for editing mode
        infoBadge.setTitle("", for: .normal)
        infoBadge.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoBadge.tintColor = .systemBlue
        infoBadge.backgroundColor = .clear
        infoBadge.isHidden = true // Hidden by default, shows when editing
    }
    
    func focusOnTitle() {
        titleTF.becomeFirstResponder()
    }
}
