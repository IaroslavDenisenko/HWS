//
//  GameScene.swift
//  MilestoneProject6
//
//  Created by Iaroslav Denisenko on 18.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var bulletsLabel: SKLabelNode!
    var reloadClip: SKLabelNode!
    var gameTimer: Timer!
    var bullets = 6 {
        didSet {
            bulletsLabel.text = "bullets: \(bullets)"
        }
    }
    var timer = 60 {
        didSet {
            timerLabel.text = "Time: \(timer)"
        }
    }
    let friends = [
        "tigercute",
        "cartoonCrab",
        "mermaid",
        "doctor",
        "dog",
        "spaceman"
    ]
    let enemies = [
        "baloonRed",
        "baloonGreen",
        "baloonPink",
        "baloonBlue",
        "baloonYellow",
        "hero",
        "heroine",
        "tiger",
        "pirate"
    ]
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var isOver = false
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 700)
        addChild(scoreLabel)
        score = 0
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.position = CGPoint(x: 980, y: 700)
        addChild(timerLabel)
        timer = 60
        
        reloadClip = SKLabelNode(fontNamed: "Chalkduster")
        reloadClip.horizontalAlignmentMode = .right
        reloadClip.position = CGPoint(x: 980, y: 16)
        reloadClip.text = "Reload"
        addChild(reloadClip)
        
        bulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletsLabel.horizontalAlignmentMode = .left
        bulletsLabel.position = CGPoint(x: 16, y: 16)
        addChild(bulletsLabel)
        bullets = 6
        
        createTarget(at: CGPoint(x: -200, y: 128), movesTo: 1200)
        createTarget(at: CGPoint(x: 1200, y: 384), movesTo: -200)
        createTarget(at: CGPoint(x: -200, y: 640), movesTo: 1200)
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] _ in
            self.timer -= 1
            if self.timer < 1 {
                self.gameOver()
            }
        })
    }
    
    func createTarget(at position: CGPoint, movesTo point: CGFloat) {
        guard isOver == false else { return }
        guard let target = (friends + enemies).randomElement() else { return }
        let character = SKSpriteNode(imageNamed: target)
        var characterName = friends.contains(target) ? "friend" : "enemy"
        character.position = position
        addChild(character)
        let duration = Double.random(in: 1...10)
        characterName += duration < 3 ? "Fast" : ""
        character.name = characterName
        character.run(SKAction.moveTo(x: point, duration: duration)) { [weak character] in
            character?.removeFromParent()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.createTarget(at: position, movesTo: point)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isOver == false else { return }
        guard let touch = touches.first else { return }
        bullets -= bullets > 0 ? 1 : 0
        if bullets < 1 {
            reloadClip.setScale(2.0)
        }
        let position = touch.location(in: self)
        let hitNodes = nodes(at: position)
        if hitNodes.contains(reloadClip) {
            reloadClip.setScale(1.0)
            bullets = 6
        }
        guard bullets > 0 else { return }
        for node in hitNodes {
            switch node.name {
            case "enemyFast":
                score += 3
            case "enemy":
                score += 1
            case "friendFast":
                score -= score > 0 ? 1 : 0
            case "friend":
                score -= score > 2 ? 3 : score
            default:
                continue
            }
            hit(node: node)
        }
    }

    func hit(node: SKNode) {
        if let blood = SKEmitterNode(fileNamed: "Smoke") {
            blood.position = node.position
            addChild(blood)
        }
        node.removeFromParent()
    }
    
    func gameOver() {
        gameTimer.invalidate()
        isOver = true
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
    }
}
