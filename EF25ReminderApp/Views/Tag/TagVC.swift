//
//  TagVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class TagVC: UIViewController {
    var onSelect: (([Tag]) -> Void)?
    var selectedTags: [Tag] = [] // Add this property
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
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let newHeight = max(contentHeight + 24, 120) 
        containerHeight.constant = newHeight
        print("TagVC container height set to: \(newHeight), content height: \(contentHeight)")
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
        print("Loaded \(tags.count) tags: \(tags.map { $0.name })")
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for (index, tag) in self.tags.enumerated() {
                if self.selectedTags.contains(where: { $0.id == tag.id }) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
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
//                let tag = ReminderRealmManager.shared.ensureTag(named: name, colorKey: hex)
                self.loadTags()
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
        print("TagVC numberOfItemsInSection: \(tags.count)")
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("TagVC cellForItemAt: \(indexPath.item) - \(tags[indexPath.item].name)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(tag: tags[indexPath.item])
        return cell
    }
}

extension TagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Selection is handled automatically by the collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Deselection is handled automatically by the collection view
    }
}

extension TagVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tags[indexPath.item].name as NSString
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let size = text.size(withAttributes: [.font: font])
        let width = max(size.width + 24, 80) // Minimum width of 80
        return CGSize(width: width, height: 36)
    }
}


