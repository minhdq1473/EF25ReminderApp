//
//  TagCell.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class TagCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var view: UIView!
    
    private var currentTag: Tag?

    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 8
    }
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                view.backgroundColor = currentTag?.uiColor
                label.textColor = .white
            } else {
                view.backgroundColor = .systemGray5
                label.textColor = .label
            }
        }
    }
    
    private func setupView() {
        
    }

    func configure(tag: Tag) {
        currentTag = tag
        label.text = tag.name
        print("Configuring tag: \(tag.name) with color: \(tag.color)")
        
        if isSelected {
            view.backgroundColor = tag.uiColor
            label.textColor = .white
        } else {
            view.backgroundColor = .neutral3
            label.textColor = .label
        }
    }
}
