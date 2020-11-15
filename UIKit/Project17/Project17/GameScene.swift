//
//  GameScene.swift
//  Project17
//
//  Created by Iaroslav Denisenko on 13.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    let possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    var isSelected = false
    var timeInterval = 2.0 {
        didSet {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemies), userInfo: nil, repeats: true)
        }
    }
    var numberOfEnemies = 0 {
        didSet {
            if numberOfEnemies.isMultiple(of: 20) {
                timeInterval -= 0.1
            }
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemies), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemies() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        let spriteEnemy = SKSpriteNode(imageNamed: enemy)
        spriteEnemy.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(spriteEnemy)
        
        spriteEnemy.physicsBody = SKPhysicsBody(texture: spriteEnemy.texture!, size: spriteEnemy.size)
        spriteEnemy.physicsBody?.categoryBitMask = 1
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        spriteEnemy.physicsBody?.angularVelocity = 5
        spriteEnemy.physicsBody?.linearDamping = 0
        spriteEnemy.physicsBody?.angularDamping = 0
        
        numberOfEnemies += 1
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        } else {
            gameTimer?.invalidate()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(player) {
            isSelected = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        if isSelected {
            if location.y < 100 {
                location.y = 100
            } else if location.y > 730 {
                location.y = 730
            }
            if location.x < 50 {
                location.x = 50
            } else if location.x > 950 {
                location.x = 950
            }
            player.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            isSelected = false
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        isGameOver = true
    }
}
