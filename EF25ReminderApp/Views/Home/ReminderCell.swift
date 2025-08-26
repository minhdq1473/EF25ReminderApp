//
//  ReminderCell.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class ReminderCell: UITableViewCell {
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagBadge: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with reminder: Reminder) {
        titleLabel.text = reminder.title
        if let date = reminder.dueDate {
            let df = DateFormatter()
            df.dateFormat = "MMM d, yyyy"
            dateLabel.text = df.string(from: date)
        } else {
            dateLabel.text = nil
        }
        let names = reminder.tags.map { $0.name }
        if names.isEmpty {
            tagBadge.text = "None"
            tagBadge.backgroundColor = .clear
            tagBadge.textColor = .secondaryLabel
        } else {
            tagBadge.text = names.joined(separator: ", ")
            tagBadge.backgroundColor = .clear
            tagBadge.textColor = .label
        }
    }
}
