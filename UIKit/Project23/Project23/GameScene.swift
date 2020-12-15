//
//  GameScene.swift
//  Project23
//
//  Created by Iaroslav Denisenko on 13.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

enum ForceBomb {
    case always, never, random
}

class GameScene: SKScene {

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "score: \(score)"
        }
    }
    var livesImages = [SKSpriteNode]()
    var lives = 3
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupScoreLabel()
        setupLives()
        setupSlices()
        startGame()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
    }
    
    func setupScoreLabel() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        score = 0
    }
    
    func setupLives() {
        for i in 1...3 {
            let life = SKSpriteNode(imageNamed: "sliceLife")
            life.position = CGPoint(x: 750 + (i * 70), y: 720)
            addChild(life)
            livesImages.append(life)
        }
    }
    
    func setupSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        activeSliceBG.lineWidth = 9
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        addChild(activeSliceBG)
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        activeSliceFG.lineWidth = 5
        activeSliceFG.strokeColor = .white
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceFG.path = nil
            activeSliceBG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceFG.path = path.cgPath
        activeSliceBG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        let randomNumber = Int.random(in: 1...3)
        let playSound = SKAction.playSoundFileNamed("swoosh\(randomNumber).caf", waitForCompletion: true)
        run(playSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        activeSlicePoints.removeAll(keepingCapacity: true)
        activeSlicePoints.append(point)
        redrawActiveSlice()
        activeSliceFG.removeAllActions()
        activeSliceBG.removeAllActions()
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    fileprivate func hitNodeHandler(_ node: SKSpriteNode, emitterName: String, soundName: String) {
        if let emitter = SKEmitterNode(fileNamed: emitterName) {
            emitter.position = node.position
            addChild(emitter)
        }
        node.physicsBody?.isDynamic = false
        let scaleOut = SKAction.scale(to: 0.01, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        let seq = SKAction.sequence([group, .removeFromParent()])
        node.run(seq)
        if let index = activeEnemies.firstIndex(of: node) {
            activeEnemies.remove(at: index)
        }
        run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded {
            return
        }
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        activeSlicePoints.append(point)
        redrawActiveSlice()
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: point)
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                score += 1
                node.name = ""
                hitNodeHandler(node, emitterName: "sliceHitEnemy", soundName: "whack.caf")
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                node.name = ""
                hitNodeHandler(bombContainer, emitterName: "sliceHitBomb", soundName: "explosion.caf")
               endGame(triggeredByBomb: true)
            } else if node.name == "spaceman" {
                score += 5
                node.name = ""
                hitNodeHandler(node, emitterName: "sliceHitEnemy", soundName: "whack.caf")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        if isGameEnded {
            return
        }
        let enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .always {
            enemyType = 0
        } else if forceBomb == .never {
            enemyType = 1
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bomb = SKSpriteNode(imageNamed: "sliceBomb")
            bomb.name = "bomb"
            enemy.addChild(bomb)
            
            if let fuse = SKEmitterNode(fileNamed: "sliceFuse") {
                fuse.position = CGPoint(x: 76, y: 64)
                enemy.addChild(fuse)
            }
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
        } else if enemyType == 2 {
            enemy = SKSpriteNode(imageNamed: "spaceman")
            enemy.name = "spaceman"
            run(SKAction.playSoundFileNamed("spaceman.mp3", waitForCompletion: false))
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = "enemy"
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        }
        // enemy position
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition

        let randomAngularVelocity = CGFloat.random(in: -3...3 )
        let randomXVelocity: Int

        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }

        let randomYVelocity = Int.random(in: 24...32)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        if enemyType == 2 {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 50, dy: randomYVelocity * 50)
        } else {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        }
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies() {
        if isGameEnded {
            return
        }
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)

        case .one:
            createEnemy()

        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)

        case .two:
            createEnemy()
            createEnemy()

        case .three:
            createEnemy()
            createEnemy()
            createEnemy()

        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()

        case .chain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }

        case .fastChain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }

        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func startGame() {
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        var life: SKSpriteNode
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }
        isGameEnded = true
//        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            for i in 0...2 {
                livesImages[i].texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
        run(SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false))
    }
      
    override func update(_ currentTime: TimeInterval) {
        let bombs = activeEnemies.filter { $0.name == "bombContainer" }
        if bombs.count == 0 {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    if node.name == "enemy" || node.name ==  "spaceman" {
                        subtractLife()
                    }
                    node.removeAllActions()
                    node.name = ""
                    node.removeFromParent()
                    activeEnemies.remove(at: index)
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
    }
}
