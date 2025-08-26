//
//  TagVC.swift
//  EF25ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 25/8/25.
//

import UIKit

class TagVC: UIViewController {
    var onSelect: (([Tag]) -> Void)?
    var selectedTags: [Tag] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        loadTags()
    }
    
    private func setupNavigationBar() {
        title = "Tags"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItems = [done]
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
            
        containerView.layer.cornerRadius = 16
        
    }
    
    private func loadTags() {
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for (index, tag) in Tag.allCases.enumerated() {
                if self.selectedTags.contains(tag) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        let selected = collectionView.indexPathsForSelectedItems ?? []
        let chosen = selected.map { Tag.allCases[$0.item] }
        onSelect?(chosen)
        dismiss(animated: true)
    }
}

extension TagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("TagVC numberOfItemsInSection: \(Tag.allCases.count)")
        return Tag.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = Tag.allCases[indexPath.item]
        print("TagVC cellForItemAt: \(indexPath.item) - \(tag.rawValue)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(tag: tag)
        return cell
    }
}

extension TagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}




