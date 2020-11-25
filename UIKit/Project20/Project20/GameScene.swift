//
//  GameScene.swift
//  Project20
//
//  Created by Iaroslav Denisenko on 24.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer!
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    var numLaunchesLabel: SKLabelNode!
    var isGameOver = false
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    var score = 0 {
        didSet {
            scoreLabel.text = "score: \(score)"
        }
    }
    var numLaunches = 0 {
        didSet {
            numLaunchesLabel.text = "launches: \(numLaunches)"
            if numLaunches > 9 {
                gameTimer.invalidate()
                isGameOver = true
            }
        }
    }
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        
        numLaunchesLabel = SKLabelNode(fontNamed: "chalkduster")
        numLaunchesLabel.position = CGPoint(x: 1000, y: 16)
        numLaunchesLabel.horizontalAlignmentMode = .right
        addChild(numLaunchesLabel)
        numLaunches = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFirework), userInfo: nil, repeats: true)
    }
    
    func createFirework(xMovement: Int, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .red
        case 2:
            firework.color = .green
        default:
            break
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 100)
        node.run(move)
        
        if let fuse = SKEmitterNode(fileNamed: "fuse") {
            fuse.position = CGPoint(x: 0, y: -22)
            node.addChild(fuse)
        }
        
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFirework() {
        let movement = 1800
        numLaunches += 1
        
        switch Int.random(in: 0...3) {
        case 0:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            createFirework(xMovement: 0,    x: 512, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 100,  x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200,  x: 512 + 200, y: bottomEdge)
        case 2:
            createFirework(
                xMovement: movement, x: leftEdge, y: bottomEdge
            )
            createFirework(
                xMovement: movement, x: leftEdge, y: bottomEdge + 100
            )
            createFirework(
                xMovement: movement, x: leftEdge, y: bottomEdge + 200
            )
            createFirework(
                xMovement: movement, x: leftEdge, y: bottomEdge + 300
            )
            createFirework(
                xMovement: movement, x: leftEdge, y: bottomEdge + 400
            )
        case 3:
            createFirework(
                xMovement: -movement, x: rightEdge, y: bottomEdge
            )
            createFirework(
                xMovement: -movement, x: rightEdge, y: bottomEdge + 100
            )
            createFirework(
                xMovement: -movement, x: rightEdge, y: bottomEdge + 200
            )
            createFirework(
                xMovement: -movement, x: rightEdge, y: bottomEdge + 300
            )
            createFirework(
                xMovement: -movement, x: rightEdge, y: bottomEdge + 400
            )
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            node.name = "selected"
            node.colorBlendFactor = 0
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        for (index, node) in fireworks.enumerated().reversed() {
            if node.position.y > 900 {
                fireworks.remove(at: index)
                node.removeFromParent()
            }
        }
        if isGameOver && fireworks.filter({$0.position.y < 900
        }).isEmpty {
            gameOver()
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            let wait = SKAction.wait(forDuration: 2)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([wait, remove])
            emitter.run(seq)
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, node) in fireworks.enumerated().reversed() {
            guard let firework = node.children.first as? SKSpriteNode else { continue }
            if firework.name == "selected" {
                explode(firework: node)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func gameOver() {
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
    }
}
