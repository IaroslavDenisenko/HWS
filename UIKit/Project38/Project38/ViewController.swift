//
//  ViewController.swift
//  Project38
//
//  Created by Iaroslav Denisenko on 04.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var container: NSPersistentContainer!
    let url = "https://api.github.com/repos/apple/swift/commits?per_page=100"
//    var commits = [Commit]()
    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainer()
        loadSavedData()
        performSelector(inBackground: #selector(requestData), with: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterCommits))
    }
    
    //MARK: - CoreDataMethods
    
    func setupContainer() {
        container = NSPersistentContainer(name: "Project38")
        container.loadPersistentStores { [weak self] (persistentStoreDescription, error) in
            self?.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    @objc func filterCommits() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            let filter = "I fixed a bug in Swift"
            self.commitPredicate = NSPredicate(format: "message == %@", filter)
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default, handler: { [unowned self] _ in
            let filter = "Merge pull request"
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH %@", filter)
            self.loadSavedData()
        }))
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default, handler: { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        }))
        ac.addAction(UIAlertAction(title: "Show only Roberts's commits", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Robert Widmann'")
            self.loadSavedData()
        }))
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    @objc func requestData() {
        let newestDate = getNewestDate()
        guard let jsonString = try? String(contentsOf: URL(string: url + "&since=\(newestDate)")!) else { return }
        let jsonCommits = JSON(parseJSON: jsonString).arrayValue
        print("Number of fetched new commits is \(jsonCommits.count)")
        CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.defaultMode as CFTypeRef) { [unowned self] in
            for jsonCommit in jsonCommits {
                let commit = Commit(context: self.container.viewContext)
                self.configure(commit: commit, from: jsonCommit)
            }
            self.saveContext()
            self.loadSavedData()
        }
    }
    
    func getNewestDate() -> String {
        let formatter = ISO8601DateFormatter()
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(request) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    func configure(commit: Commit, from json: JSON) {
        let commitDate = json["commit"]["committer"]["date"].stringValue
        commit.date = ISO8601DateFormatter().date(from: commitDate) ?? Date()
        commit.message = json["commit"]["message"].stringValue
        commit.sha = json["sha"].stringValue
        commit.url = json["html_url"].stringValue
        
        var commitAuthor: Author!
        let authorName = json["commit"]["committer"]["name"].stringValue
        let predicate = NSPredicate(format: "name == %@", authorName)
        let authorFetchRequest = Author.createFetchRequest()
        authorFetchRequest.predicate = predicate
        
        if let authors = try? container.viewContext.fetch(authorFetchRequest) {
            if authors.count > 0 {
                 commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            commitAuthor = Author(context: container.viewContext)
            commitAuthor.name = authorName
            commitAuthor.email = json["commit"]["committer"]["email"].stringValue
        }
        
        commit.author = commitAuthor
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            let request = Commit.createFetchRequest()
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        do {
//            try commits = container.viewContext.fetch(request)
//            print("\(commits.count) commits loaded")
            try fetchedResultsController.performFetch()
            print("\(fetchedResultsController.fetchedObjects?.count ?? 0) commits loaded")
            tableView.reloadData()
        } catch {
            print("Loading commits error")
        }
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fetchedResultsController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.commit = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
//            commits.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .left)
            saveContext()
        }
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .left)
        default:
            break
        }
    }
}

