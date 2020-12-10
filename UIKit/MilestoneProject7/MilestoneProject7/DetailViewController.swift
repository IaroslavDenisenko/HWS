//
//  DetailViewController.swift
//  MilestoneProject7
//
//  Created by Iaroslav Denisenko on 27.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UITextView!
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupBars()
        subscribeToKeyboardNotifications()
        firstResponderSetup()
    }
    
    func firstResponderSetup() {
        if titleTextField.text!.isEmpty {
            titleTextField.becomeFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
        titleTextField.delegate = self
    }
    
    func setupBars() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveNote))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        navigationItem.rightBarButtonItems = [doneButton, actionButton]
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func loadData() {
        titleTextField.text = note?.title
        textView.text = note?.text
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustKeyboard(notification: NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenFrame = keyboardFrameValue.cgRectValue
        let keyboardViewFrame = view.convert(keyboardScreenFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        textView.scrollIndicatorInsets = textView.contentInset
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func shareNote() {
        let ac = UIActivityViewController(activityItems: [titleTextField.text!, textView.text!], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[1]
        present(ac, animated: true)
    }
    
    @objc func saveNote() {
        guard let title = titleTextField.text,
            !title.isEmpty else {
            showAlert(title: "Warning", message: "Note without a title cannot be save! Please provide the title", actionTitle: "OK", handler: nil)
            return
        }
        navigationController?.popViewController(animated: true)
        if let priorVC = navigationController?.topViewController as? ViewController {
            if let note = self.note {
                note.title = title
                note.text = textView.text ?? ""
                if let indexPath = priorVC.tableView.indexPathForSelectedRow {
                    priorVC.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else {
                let note = Note(title: title, text: textView.text ?? "")
                priorVC.folder.items.append(note)   
                let indexPath = IndexPath(row: priorVC.folder.items.count - 1, section: 0)
                priorVC.tableView.insertRows(at: [indexPath], with: .left)
            }
            priorVC.save()
        }
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
