//
//  TagVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class TagVC: UIViewController {
    var onSelect: (([Tag]) -> Void)?
    private var tags: [Tag] = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        loadTags()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerHeight.constant = collectionView.contentSize.height + 24
//        containerHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height + 24
    }
    
    private func setupNavigationBar() {
        title = "Tags"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItems = [done, add]
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true

    }
    
    private func loadTags() {
        tags = ReminderRealmManager.shared.getAllTags()
        collectionView.reloadData()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addTapped() {
        let alert = UIAlertController(title: "New Tag", message: "Enter a name", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            self.presentColorPicker(forName: name)
        }))
        present(alert, animated: true)
    }

    private func presentColorPicker(forName name: String) {
        let palette: [(String, String)] = [
            ("Blue", "systemBlue"),
            ("Orange", "systemOrange"),
            ("Green", "systemGreen"),
            ("Purple", "systemPurple"),
            ("Red", "systemRed"),
            ("Teal", "systemTeal")
        ]
        let sheet = UIAlertController(title: "Choose a color", message: nil, preferredStyle: .actionSheet)
        for (title, hex) in palette {
            sheet.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                let tag = ReminderRealmManager.shared.ensureTag(named: name, colorKey: hex)
                self.tags.append(tag)
                self.collectionView.reloadData()
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    @objc private func doneTapped() {
        let selected = collectionView.indexPathsForSelectedItems ?? []
        let chosen = selected.map { tags[$0.item] }
        onSelect?(chosen)
        dismiss(animated: true)
    }
}

extension TagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(tag: tags[indexPath.item])
        return cell
    }
}

extension TagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // wait for Done
    }
}

extension TagVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tags[indexPath.item].name as NSString
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let size = text.size(withAttributes: [.font: font])
        return CGSize(width: size.width, height: 27)
    }
}


