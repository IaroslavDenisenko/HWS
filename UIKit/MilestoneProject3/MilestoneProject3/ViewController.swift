//
//  ViewController.swift
//  MilestoneProject3
//
//  Created by Iaroslav Denisenko on 08.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    var attempts = 3 {
        didSet {
            title = "Level \(level) \t Attempts remain: \(attempts)"
        }
    }
    var answerText = "" {
        didSet {
            answerLabel.text = answerText
        }
    }
    var guessedLetters = 0
    var answer = ""
    var answerLetters = [String]()
    var usedLetters = [String]()
    var levels = [String]()
    var level = 0 {
        didSet {
            title = "Level \(level) \t Attempts remain: \(attempts)"
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        level = 1
        loadFile()
        loadLevel()
    }
    
    func loadFile() {
        guard let url = Bundle.main.url(forResource: "Words", withExtension: "txt") else { return }
        guard let fileContent = try? String(contentsOf: url)
        else { return }
        let strings =
            fileContent.replacingOccurrences(of: "\n", with: "")
        let components = strings.components(separatedBy: "В.: ")
        for i in 1..<components.count {
            levels.append(components[i])
        }
        levels.shuffle()
    }
    
    func loadLevel() {
        let levelString = levels[level - 1]
        let components = levelString.components(separatedBy: "О.: ")
        questionLabel.text = components[0]
        answer = components[1].lowercased()
        var text = ""
        answerLetters.removeAll()
        usedLetters.removeAll()
        guessedLetters = 0
        attempts = 3
        for letter in answer {
            answerLetters.append(String(letter))
            text += "?"
        }
        answerText = text
    }


    @IBAction func wordTapped() {
        let ac = UIAlertController(title: "Enter the word", message: "Are you ready to enter a whole word?", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak ac, unowned self] _ in
            guard let text = ac?.textFields?[0].text else { return }
            if text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == self.answer {
                self.answerText = self.answer
                self.score += self.answer.count - self.guessedLetters
                self.showAlert(title: "Well done!", message: "Let's go to new level")
            } else {
                self.attempts -= 1
                if self.attempts < 1 {
                    self.restartGame()
                } else {
                    self.showAlert(title: "Wrong answer", message: "Think better")
                    if self.score > 0 {
                        self.score -= 1
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "NO", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func letterTapped() {
        let ac = UIAlertController(title: "Enter a letter", message: nil, preferredStyle: .alert)
        ac.addTextField { [unowned self] textField in
            textField.delegate = self
            textField.clearButtonMode = .always
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac, unowned self] _ in
            guard let text = ac?.textFields?[0].text else { return }
            if text.isEmpty {
                self.showAlert(title: "Empty string", message: "You don't enter any letter")
                return
            }
            let lowerText = text.lowercased()
            if self.usedLetters.contains(lowerText) {
                self.showAlert(title: "repetitive letter", message: "This letter is already used")
                return
            }
            self.usedLetters.append(lowerText)
            let indexes = self.findAllOccurencies(of: lowerText, in: self.answerLetters)
            if indexes.isEmpty {
                self.attempts -= 1
                if self.attempts < 1 {
                    self.restartGame()
                } else {
                    self.showAlert(title: "Wrong letter", message: "The word doesn't contain this letter")
                    if self.score > 0 {
                        self.score -= 1
                    }
                }
                return
            }
            var answerArray = [String]()
            for character in self.answerText {
                answerArray.append(String(character))
            }
            for index in indexes {
                answerArray[index] = self.answerLetters[index]
            }
            self.answerText = answerArray.joined()
            self.attempts += 1
            self.guessedLetters += indexes.count
            self.score += indexes.count
            if self.answerText == self.answer {
                self.showAlert(title: "Well done!", message: "Let's go to new level")
            } else {
                self.showAlert(title: "Very Well", message: "This letter is in the word!")
            }
        }))
        present(ac, animated: true)
    }
    
    func showAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var handler: ((UIAlertAction) -> Void)?
        if title == "Well done!" {
            handler = { [unowned self] _ in
                self.level += 1
                if self.level < self.levels.count {
                    self.loadLevel()
                } else {
                    self.restartGame()
                }
            }
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    func findAllOccurencies(of letter: String, in word: [String]) -> [Int] {
        var result = [Int]()
        if let lastIndex = word.lastIndex(of: letter) {
            result.append(lastIndex)
            let newWord = Array(word[0..<lastIndex])
            result += findAllOccurencies(of: letter, in: newWord)
        }
        return result
    }
    
    func restartGame() {
        if level >= levels.count {
            showAlert(title: "Congratulations! You won the game!", message: "Game will start from level 1")
        } else {
            showAlert(title: "GAME OVER", message: "Your attempts are over. Game will start from level 1")
        }
        score = 0
        level = 1
        loadLevel()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        return text.count < 1
    }
   
}

