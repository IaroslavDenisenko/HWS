//
//  ViewController.swift
//  MilestoneProject7
//
//  Created by Iaroslav Denisenko on 27.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

final class ViewController: UITableViewController, UISearchBarDelegate {
    
    var items: [NotesItem]?
    var isEditable = false
    var folder: Folder!


    override func viewDidLoad() {
        super.viewDidLoad()
        folderInit()
        setupNavigationBar()
        setupToolbar()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let items = items {
            folder.items = items
        }
        tableView.reloadData()
    }
    
    func folderInit() {
        if folder == nil {
            folder = Folder(title: "Notes")
        }
    }

    func setupToolbar() {
        let addFolder = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(createFolder))
        let addNote = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil,    action: nil)
        setToolbarItems([addFolder, space, addNote], animated: true)
    }
    
    func setupNavigationBar() {
        title = folder.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
    }
    

    func load() {
        guard navigationController?.viewControllers.count == 1  else { return }
        folder.id = "Notes"
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            self.loadItems(in: self.folder)
            let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
            let folder = path[0]
            NSLog("Your NSUserDefaults are stored in this folder: \(folder)/Preferences")
        }
    }
    
    func loadItems(in folder: Folder) {
        let decoder = JSONDecoder()
        let folderKey = folder.id + "Folders"
        if let data = UserDefaults.standard.data(forKey: folderKey) {
            if let folders = try? decoder.decode([Folder].self, from: data) {
                folder.items = folders.sorted(by: {
                    return $1.title > $0.title
                })
                for folder in folders {
                    loadItems(in: folder)
                }
            }
        }
        let notesKey = folder.id + "Notes"
        if let data = UserDefaults.standard.data(forKey: notesKey) {
            if let notes = try? decoder.decode([Note].self, from: data) {
                folder.items += notes.sorted(by: {
                    return $1.title > $0.title
                })
            }
        }
    }

    
    @objc func toggleEditMode() {
        isEditable.toggle()
        if isEditable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(toggleEditMode))
            tableView.setEditing(true, animated: true)
            tableView.allowsSelectionDuringEditing = true
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditMode))
            tableView.setEditing(false, animated: true)
        }
    }
    
    @objc func createFolder() {
        let ac = UIAlertController(title: "New Folder", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default)
        { [unowned ac, unowned self] _ in
            if let text = ac.textFields?[0].text {
                let folder = Folder(title: text)
                self.folder.items.append(folder)
                let indexPath = IndexPath(row: self.folder.items.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .left)
                self.save()
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func createNote() {
        guard let noteController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        noteController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(noteController, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folder.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let item = folder.items[indexPath.row]
        if let folder = item as? Folder {
            cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = folder.title
            cell.detailTextLabel?.text = String(folder.items.count)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
            cell.textLabel?.text = item.title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = folder.items[indexPath.row]
        if let folder = item as? Folder {
            if isEditable {
                changeFolderName(folder: folder, for: indexPath)
            } else {
                if let folderVC = storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController {
                    folderVC.folder = folder
                    navigationController?.pushViewController(folderVC, animated: true)
                }
            }
        } else if let note = item as? Note {
            if let noteVC = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController {
                noteVC.note = note
                noteVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(noteVC, animated: true)
            }
        }
    }
    
    func changeFolderName(folder: Folder, for indexPath: IndexPath ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "Change folder's name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = folder.title
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac, weak folder, weak self] _ in
            if let text = ac?.textFields?[0].text {
                folder?.title = text
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.save()
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    func save() {
        guard let rootVC = self.navigationController?.viewControllers[0] as? ViewController else { return }
        DispatchQueue.global(qos: .utility).async { [unowned rootVC, unowned self] in
            self.saveItems(in: rootVC.folder)
        }
    }
    
    func saveItems(in folder: Folder) {
        let encoder = JSONEncoder()
        let folders = folder.items.compactMap { $0 as? Folder }
        let foldersKey = folder.id + "Folders"
        if let foldersData = try? encoder.encode(folders) {
            UserDefaults.standard.set(foldersData, forKey: foldersKey)
        }
        let notes = folder.items.compactMap { $0 as? Note }
        let notesKey = folder.id + "Notes"
        if let notesData = try? encoder.encode(notes) {
            UserDefaults.standard.set(notesData, forKey: notesKey)
        }
        for folder in folders {
            saveItems(in: folder)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if items != nil {
            folder.items = items!
            tableView.reloadData()
        } else {
            items = folder.items
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let searchItems = self.items!.filter {$0.title.lowercased().contains(searchText.lowercased())}
            self.folder.items = searchText.isEmpty ? self.items! : searchItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        folder.items = items!
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = folder.items[indexPath.row]
        folder.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .right)
        deleteItem(item)
        save()
    }
    
    func deleteSingleFolder(with id: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let foldersKey = id + "Folders"
            let notesKey = id + "Notes"
            UserDefaults.standard.removeObject(forKey: foldersKey)
            UserDefaults.standard.removeObject(forKey: notesKey)
        }
    }
    
    
    func deleteItem(_ item: NotesItem) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let folder = item as? Folder {
                self?.deleteSingleFolder(with: folder.id)
                for folder in folder.items {
                    self?.deleteItem(folder)
                }
            }
        }
    }
}

