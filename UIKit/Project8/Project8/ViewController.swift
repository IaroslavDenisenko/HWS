//
//  ViewController.swift
//  Project8
//
//  Created by Iaroslav Denisenko on 05.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var scoreLabel: UILabel!
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var submitButton: UIButton!
    var clearButton: UIButton!
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var numberOfAnswers = 0
    var level = 1
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        setupScoreLabel()
        setupCluesLabel()
        setupAnswersLabel()
        setupCurrentAnswer()
        setupControlButtons()
        setupButtonsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
    }
    
    func setupScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.text = "Score: \(score)"
        scoreLabel.textAlignment = .right
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    func setupCluesLabel() {
        cluesLabel = UILabel()
        cluesLabel.text = "CLUES"
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.numberOfLines = 0
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        NSLayoutConstraint.activate([
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100)
        ])
    }
    
    func setupAnswersLabel() {
        answersLabel = UILabel()
        answersLabel.text = "ANSWERS"
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        NSLayoutConstraint.activate([
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor)
        ])
    }
    
    func setupCurrentAnswer() {
        currentAnswer = UITextField()
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentAnswer)
        NSLayoutConstraint.activate([
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func setupControlButtons() {
        submitButton = UIButton(type: .system)
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submiTapped(_:)), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        clearButton = UIButton(type: .system)
        clearButton.setTitle("CLEAR", for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped(_:)), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupButtonsView() {
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        NSLayoutConstraint.activate([
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320)
        ])
        
        let width = 150
        let heigh = 80
        
        for row in 0..<4 {
            for col in 0..<5 {
                let frame = CGRect(x: col * width, y: row * heigh, width: width, height: heigh)
                let button = UIButton(type: .system)
                button.frame = frame
                button.setTitle("WWW", for: .normal)
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.layer.borderWidth = 1.0
                button.layer.cornerRadius = 5.0
                button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
                buttonsView.addSubview(button)
                letterButtons.append(button)
            }
        }
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        guard let url = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else { return }
        guard let levelContent = try? String(contentsOf: url) else { return }
        var lines = levelContent.components(separatedBy: "\n")
        lines.shuffle()
        for (index, line) in lines.enumerated() {
            let components = line.components(separatedBy: ": ")
            let answer = components[0]
            let clue = components[1]
            clueString += "\(index + 1). \(clue)\n"
            let solution = answer.replacingOccurrences(of: "|", with: "")
            solutionString += "\(solution.count) letters\n"
            solutions.append(solution)
            let bits = answer.components(separatedBy: "|")
            letterBits += bits
        }
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        letterBits.shuffle()
        if letterBits.count == letterButtons.count {
            for i in 0..<letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    @objc func submiTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        guard let solutionPositon = solutions.firstIndex(of: answerText) else {
            if score > 0 {
                score -= 1
            }
            presentAlert(title: "Wrong answer!",
                         message: "Try another letters",
                         actionTitle: "OK",
                         actionHandler: nil)
            return
        }
        
        currentAnswer.text = ""
        score += 1
        activatedButtons.removeAll()
        numberOfAnswers += 1
        
        var splitAnwsers = answersLabel.text?.components(separatedBy: "\n")
        splitAnwsers?[solutionPositon] = answerText
        answersLabel.text = splitAnwsers?.joined(separator: "\n")
        
        if numberOfAnswers % 7 == 0 {
            presentAlert(title: "Well Done!",
                         message: "Are you redy for level 2?",
                         actionTitle: "Let's go",
                         actionHandler: newLevel)
        }
    }
    
    func presentAlert(title: String, message: String?, actionTitle: String, actionHandler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
        present(ac, animated: true)
    }
    
    func newLevel(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        
        for button in letterButtons {
            button.isHidden = false
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        for button in activatedButtons {
            button.isHidden = false
        }
        activatedButtons.removeAll()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isHidden = true
    }
}

