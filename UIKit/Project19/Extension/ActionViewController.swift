//
//  ActionViewController.swift
//  Extension
//
//  Created by Iaroslav Denisenko on 19.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    var savingAlertTextfield: UITextField!
    var hostname: String?
    var pageTitle = ""
    var pageURL = ""
    var info = """
    document.write("Вы пришли с <b>"+document.referrer+"</b>");
    document.write("<BR>Ваш броузер: <b>"+navigator.appName+"</b>");
    document.write("<BR>Кодовое название: <b>"+navigator.appCodeName+"</b>");
    document.write("<BR>Версия: <b>"+ navigator.appVersion+"</b>")
    document.write("<br>Заголовок пользовательского агента: <b>"+navigator.userAgent+"</b>");
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupButtons()
        subscribeToKeyboardNotifications()
    }
    
    func setupButtons() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveScript))
        navigationItem.rightBarButtonItems = [doneButton, addButton]
        let runScriptButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(runScript))
        let selectScriptButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(selectScript))
        navigationItem.leftBarButtonItems = [runScriptButton, selectScriptButton]
    }
    
    @objc func selectScript() {
        guard let tableVC = storyboard?.instantiateViewController(identifier: "TableViewController") as? TableViewController else { return }
        tableVC.host = hostname
        navigationController?.pushViewController(tableVC, animated: true)
    }
    
    @objc func saveScript(action: UIAlertAction) {
        let ac = UIAlertController(title: "Save script", message: "Choose script name for this page", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        savingAlertTextfield = ac.textFields?[0]
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: savingHandler))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
      
    func savingHandler(with action: UIAlertAction) {
        guard let url = URL(string: pageURL) else { return }
        guard let name = savingAlertTextfield.text else { return }
        var scriptDict: [String : Any]
        if let dict = UserDefaults.standard.dictionary(forKey: url.host!) {
            scriptDict = dict
        } else {
            scriptDict = [String : String]()
        }
        if !scriptDict.keys.filter({$0 == name}).isEmpty {
            let ac = UIAlertController(title: "Warning", message: "Such name is already exist! Do you want to replace it?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "YES", style: .destructive) { _ in
                scriptDict[name] = self.script.text
                UserDefaults.standard.set(scriptDict, forKey: url.host!)
            })
            ac.addAction(UIAlertAction(title: "NO", style: .default, handler: saveScript(action:)))
            present(ac, animated: true)
        } else {
            scriptDict[name] = self.script.text
            UserDefaults.standard.set(scriptDict, forKey: url.host!)
        }
    }
        
    @objc func runScript() {
        let ac = UIAlertController(title: "Scripts", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Alert", style: .default) { [weak self] _ in
            self?.run(script: "alert(document.title);")
        })
        ac.addAction(UIAlertAction(title: "Header info", style: .default, handler: { [weak self] _ in
            self?.run(script: self?.info)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(ac, animated: true)
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
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    func loadData() {
        guard let inputItem  = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        guard let itemProvider = inputItem.attachments?.first else { return }
        itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil) { [weak self] (dict, error) in
            guard let itemDictionary = dict as? NSDictionary else { return }
            guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
            self?.pageTitle = javaScriptValues["title"] as? String ?? ""
            self?.pageURL = javaScriptValues["URL"] as? String ?? ""
            if let pageURL = self?.pageURL {
                let url = URL(string: pageURL)
                self?.hostname = url?.host
            }
            DispatchQueue.main.async {
                self?.title = self?.pageTitle
            }
        }
    }

    func run(script: String?) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func done() {
        run(script: script.text)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
