//
//  GameScene.swift
//  Project26
//
//  Created by Iaroslav Denisenko on 22.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum CategoryMasks: UInt32 {
    case player = 1
    case wall   = 2
    case vortex = 4
    case star   = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK:- Instance properties
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var isGameOver = false
    
    // MARK:- Instance methods
    
    override func didMove(to view: SKView) {
        setupBackground()
        loadLevel()
        createPlayer()
        setupMotionManager()
        setupLabel()
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        #if targetEnvironment(simulator)
            if let currentPosition = lastTouchPosition {
                let diff = CGPoint(x: currentPosition.x - player.position.x,
                                   y: currentPosition.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(
                    dx: accelerometerData.acceleration.y * -50,
                    dy:accelerometerData.acceleration.x * 50)
            }
        #endif
    }
    
    // MARK: Game setup methods
        
    func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func setupBackground() {
        let backgroundImage = SKSpriteNode(imageNamed: "background@2x.jpg")
        backgroundImage.position = CGPoint(x: 512, y: 384)
        backgroundImage.blendMode = .replace
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
    }
    
    func setupLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }
        let lines = levelString.components(separatedBy: "\n")
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: 64 * column + 32, y: 64 * row + 32)
                switch letter {
                case "x":
                    createWall(at: position)
                case "v":
                    createVortex(at: position)
                case "s":
                    createStar(at: position)
                case "f":
                    createFlag(at: position)
                case " ":
                    do {
                    // this is an empty space – do nothing!
                    }
                default:
                    print("Unknow level letter: \(letter)")
                }
            }
        }
    }
    
    // MARK: Nodes creation methods
    
    func createNode(position: CGPoint, imageNamed: String) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: imageNamed)
        node.position = position
        addChild(node)
        return node
    }
    
    func createWall(at position: CGPoint) {
        let wall = createNode(position: position, imageNamed: "block")
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.categoryBitMask = CategoryMasks.wall.rawValue
        wall.physicsBody?.isDynamic = false
    }
    
    func physicsBodySetup(for node: SKSpriteNode, with categoryBitMask: UInt32) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = CategoryMasks.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
    }
    
    func createVortex(at position:CGPoint) {
        let vortex = createNode(position: position, imageNamed: "vortex")
        vortex.name = "vortex"
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi, duration: 1)))
        physicsBodySetup(for: vortex, with: CategoryMasks.vortex.rawValue)
    }
    
    func createStar(at position: CGPoint) {
        let star = createNode(position: position, imageNamed: "star")
        star.name = "star"
        physicsBodySetup(for: star, with: CategoryMasks.star.rawValue)
    }
    
    func createFlag(at position: CGPoint) {
        let flag = createNode(position: position, imageNamed: "finish")
        flag.name = "finish"
        physicsBodySetup(for: flag, with: CategoryMasks.finish.rawValue)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CategoryMasks.player.rawValue
        player.physicsBody?.contactTestBitMask = CategoryMasks.finish.rawValue | CategoryMasks.star.rawValue | CategoryMasks.vortex.rawValue
        player.physicsBody?.collisionBitMask = CategoryMasks.wall.rawValue
        addChild(player)
        physicsWorld.gravity = .zero
    }
    
    // MARK: Touches handling methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    // MARK: Nodes contact methods
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "player" {
            playerCollide(with: bodyB)
        } else {
            playerCollide(with: bodyA)
        }
    }
    
    func playerCollide(with node: SKNode) {
        switch node.name {
        case "vortex":
            isGameOver = true
            score -= score > 0 ? 1 : 0
            player.physicsBody?.isDynamic = false
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        case "star":
            score += 1
            node.removeFromParent()
        case "finish":
            do {
                // FIXME: load new level
            }
        default:
            break
        }
    }
}
