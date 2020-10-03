//
//  ViewController.swift
//  MilestoneProject2
//
//  Created by Iaroslav Denisenko on 03.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var shoppingList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        title = "Shopping list"
    }
    
    func setupButtons() {
       let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
       let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
       let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearButtonTapped))
        navigationItem.rightBarButtonItems = [shareButton, addButton]
        navigationItem.leftBarButtonItem = clearButton
    }
    
    @objc func addButtonTapped() {
        let ac = UIAlertController(title: "Add item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak ac] action in
            if let text = ac?.textFields?[0].text {
                let lowerText = text.lowercased()
                if text.isEmpty {
                    self?.makeWarning(with: "You shold enter some text")
                } else if self?.shoppingList.contains(lowerText) ?? false {
                    self?.makeWarning(with: "\(text) is already in shopping list")
                } else {
                self?.shoppingList.insert(lowerText, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        })
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func makeWarning(with message: String) {
        let ac = UIAlertController(title: "Warning!", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

    @objc func clearButtonTapped() {
        shoppingList.removeAll()
        tableView.reloadData()
    }
    
    @objc func shareButtonTapped() {
        let string = shoppingList.joined(separator: "\n")
        let alertController = UIActivityViewController(activityItems: [string], applicationActivities: [])
        alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        return cell
    }
}

